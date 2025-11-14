use http_body_util::Full;
use hyper::{Request, Response, body::Bytes};
use serde::Serialize;

use crate::stats::sysinfo::SysInfo;

mod sysinfo;

macro_rules! impl_metrics {
    ($($name:ident: $type:ty => ($cli:ident)),*) => {
        #[serde_with::skip_serializing_none]
        #[derive(Serialize, ts_rs::TS)]
        #[ts(export, optional_fields)]
        pub struct CombinedResponse {
            $($name: Option<$type>,)*
        }

        #[derive(Serialize, ts_rs::TS)]
        #[ts(export)]
        pub struct EnabledMetrics {
            $($name: bool,)*
        }

        impl EnabledMetrics {
            pub fn from_cli() -> Self {
                Self {
                    $($name: crate::cli().$cli,)*
                }
            }
        }
    };
}

impl_metrics! (
    sysinfo: SysInfo => (enable_sysinfo)
);

macro_rules! fill_option {
    ($field:ident, $type:ty) => {
        if crate::cli().$field {
            // TODO: Does this spawn all then wait, or run one at a time?
            Some(<$type>::fetch().await)
        } else {
            None
        }
    };
}

impl CombinedResponse {
    pub async fn fetch() -> Self {
        Self {
            sysinfo: fill_option!(enable_sysinfo, SysInfo),
        }
    }
}

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
