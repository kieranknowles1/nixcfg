use http_body_util::Full;
use hyper::{Request, Response, body::Bytes};
use serde::Serialize;

use crate::stats::{sysinfo::SysInfo, trilium::TriliumData};

mod sysinfo;
mod trilium;

macro_rules! impl_metrics {
    ($($name:ident: $type:ty => ($cli:ident)),*) => {
        // Each metric is represented by an optional field
        #[serde_with::skip_serializing_none]
        #[derive(Serialize, ts_rs::TS)]
        #[ts(export, optional_fields)]
        pub struct CombinedResponse {
            $($name: Option<$type>,)*
        }

        // Whether this metric is enabled, represented by a boolean
        #[derive(Serialize, ts_rs::TS)]
        #[ts(export)]
        pub struct EnabledMetrics {
            $($name: bool,)*
        }

        // Generate list of enabled metrics
        impl EnabledMetrics {
            pub fn from_cli() -> Self {
                let cli = crate::cli();
                Self {
                    $($name: cli.$cli.enable,)*
                }
            }
        }

        // Fetch all enabled metrics
        impl CombinedResponse {
            pub async fn fetch() -> Self {
                let cli = crate::cli();

                // Spawn all jobs simultaneously
                $(
                    let $name = async {
                        if cli.$cli.enable {
                            let res = <$type>::fetch().await;
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
    sysinfo: SysInfo => (sysinfo),
    trilium: TriliumData => (trilium)
);

pub async fn info_route(
    _: Request<hyper::body::Incoming>,
) -> Result<Response<Full<Bytes>>, serde_json::Error> {
    let info = EnabledMetrics::from_cli();
    let json = serde_json::to_string(&info)?;

    Ok(Response::new(Full::new(Bytes::from(json))))
}

pub async fn route(
    _: Request<hyper::body::Incoming>,
) -> Result<Response<Full<Bytes>>, serde_json::Error> {
    let stats = CombinedResponse::fetch().await;
    let json = serde_json::to_string(&stats)?;

    Ok(Response::new(Full::new(Bytes::from(json))))
}
