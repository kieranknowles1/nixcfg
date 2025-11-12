use http_body_util::Full;
use hyper::{Request, Response, body::Bytes, header::HeaderValue};
use serde::Serialize;

use crate::stats::sysinfo::SysInfo;

mod sysinfo;

#[derive(Serialize)]
pub struct CombinedResponse {
    sys_info: SysInfo,
}

impl CombinedResponse {
    pub fn fetch() -> Self {
        Self {
            sys_info: SysInfo::fetch(),
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
