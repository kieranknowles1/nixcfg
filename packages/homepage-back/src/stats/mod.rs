use http_body_util::Full;
use hyper::{Request, Response, body::Bytes, header::HeaderValue};
use serde::Serialize;

use crate::stats::sysinfo::SysInfo;

mod sysinfo;

#[serde_with::skip_serializing_none]
#[derive(Serialize)]
pub struct CombinedResponse {
    sysinfo: Option<SysInfo>,
}

macro_rules! fill_option {
    ($field:ident, $type:ty) => {
        if crate::cli().$field {
            Some(<$type>::fetch())
        } else {
            None
        }
    };
}

impl CombinedResponse {
    pub fn fetch() -> Self {
        Self {
            sysinfo: fill_option!(enable_sysinfo, SysInfo),
        }
    }
}

pub async fn route(
    _: Request<hyper::body::Incoming>,
) -> Result<Response<Full<Bytes>>, serde_json::Error> {
    let stats = CombinedResponse::fetch();
    let json = serde_json::to_string(&stats)?;

    let mut res = Response::new(Full::new(Bytes::from(json)));
    res.headers_mut()
        .insert("Content-Type", HeaderValue::from_static("application/json"));
    Ok(res)
}
