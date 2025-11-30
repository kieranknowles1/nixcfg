use http_body_util::Full;
use hyper::{Response, body::Bytes};
use serde::Serialize;
use thiserror::Error;

use crate::service::sysinfo::{StaticSysInfo, SysInfo};

pub mod sysinfo;

#[derive(Debug, Error)]
pub enum Error {
    #[error(transparent)]
    Json(#[from] serde_json::Error),
}

macro_rules! fetch_maybe {
    ($name:ident, $type:ty) => {
        let $name = async {
            if let Some(cfg) = &crate::cfg().$name {
                let res = <$type>::fetch(&cfg).await;
                if let Err(msg) = &res {
                    eprintln!("Failed to fetch {}: {}", stringify!($type), msg);
                }
                res.ok()
            } else {
                None
            }
        };
    };
}

macro_rules! impl_metrics {
    ($($name:ident: ($dyntype:ty, $statictype:ty)),*) => {
        // Each metric is represented by an optional field
        #[serde_with::skip_serializing_none]
        #[derive(Serialize, ts_rs::TS)]
        #[ts(export, optional_fields)]
        pub struct CombinedResponse {
            $($name: Option<$dyntype>,)*
        }

        #[serde_with::skip_serializing_none]
        #[derive(Serialize, ts_rs::TS)]
        #[ts(export, optional_fields)]
        pub struct StaticResponse {
            $($name: Option<$statictype>,)*
        }

        // Fetch static parts of all metrics
        impl StaticResponse {
            pub async fn fetch() -> Self {
                $(fetch_maybe!($name, $statictype);)*
                let ($($name,)*) = tokio::join!($($name,)*);

                Self { $($name,)* }
            }
        }

        // Fetch all enabled metrics
        impl CombinedResponse {
            pub async fn fetch() -> Self {
                // Spawn all jobs simultaneously
                $(fetch_maybe!($name, $dyntype);)*

                // Await all jobs, which may complete in any order
                let ($($name,)*) = tokio::join!($($name,)*);

                Self { $($name,)* }
            }
        }
    };
}

impl_metrics! (
    sysinfo: (SysInfo, StaticSysInfo)
);

pub async fn static_route() -> Result<Response<Full<Bytes>>, Error> {
    let response = StaticResponse::fetch().await;
    let json = serde_json::to_string(&response)?;

    Ok(Response::new(Full::new(Bytes::from(json))))
}

pub async fn route() -> Result<Response<Full<Bytes>>, Error> {
    let response = CombinedResponse::fetch().await;
    let json = serde_json::to_string(&response)?;

    Ok(Response::new(Full::new(Bytes::from(json))))
}
