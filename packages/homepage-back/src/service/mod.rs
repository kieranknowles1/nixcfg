use http_body_util::Full;
use hyper::{Response, StatusCode, body::Bytes};
use serde::Serialize;
use thiserror::Error;

use crate::service::sysinfo::SysInfo;

pub mod sysinfo;

#[derive(Debug, Error)]
pub enum Error {
    #[error(transparent)]
    Json(#[from] serde_json::Error),
}

macro_rules! impl_metrics {
    ($($name:ident: $type:ty),*) => {
        // Each metric is represented by an optional field
        #[serde_with::skip_serializing_none]
        #[derive(Serialize, ts_rs::TS)]
        #[ts(export, optional_fields)]
        pub struct CombinedResponse {
            $($name: Option<$type>,)*
        }

        // Fetch all enabled metrics
        impl CombinedResponse {
            pub async fn fetch() -> Self {
                let opts = crate::cfg();
                // Spawn all jobs simultaneously
                $(
                    let $name = async {
                        if let Some(cfg) = &opts.$name {
                            let res = <$type>::fetch(&cfg).await;
                            if let Err(msg) = &res {
                                eprintln!("Failed to fetch {}: {}", stringify!($type), msg);
                            }
                            res.ok()
                        } else {
                            None
                        }
                    };
                )*

                // Await all jobs, which may complete in any order
                let ($($name,)*) = tokio::join!($($name,)*);

                Self { $($name,)* }
            }
        }
    };
}

impl_metrics! (
    sysinfo: SysInfo
);

pub async fn route() -> Result<Response<Full<Bytes>>, Error> {
    let response = CombinedResponse::fetch().await;
    let json = serde_json::to_string(&response)?;

    let response = Response::builder()
        .status(StatusCode::OK)
        .header("Content-Type", "application/json")
        .body(Full::new(Bytes::from(json)))
        .expect("Response should always be valid");
    Ok(response)
}
