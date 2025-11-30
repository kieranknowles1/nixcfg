use std::{env, net::SocketAddr, sync::OnceLock};

use http_body_util::Full;
use hyper::{
    Request, Response, StatusCode, body::Bytes, header::HeaderValue, server::conn::http1,
    service::service_fn,
};
use hyper_util::rt::TokioIo;
use tokio::net::TcpListener;

use crate::service::sysinfo::SysInfoOpts;

mod service;

#[derive(serde::Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Config {
    #[serde(default = "default_port")]
    port: u16,

    sysinfo: Option<SysInfoOpts>,
}

fn default_port() -> u16 {
    8080
}

fn not_found() -> Response<Full<Bytes>> {
    Response::builder()
        .status(StatusCode::NOT_FOUND)
        .body(Full::new(Bytes::from_static(b"{\"error\": \"Not Found\"}")))
        .unwrap()
}

async fn route(
    req: Request<hyper::body::Incoming>,
) -> Result<Response<Full<Bytes>>, service::Error> {
    let mut res = match req.uri().path() {
        "/system" => crate::service::static_route().await?,
        "/status" => crate::service::route().await?,
        _ => not_found(),
    };

    // TODO: Is this header the correct one for production?
    res.headers_mut()
        .insert("Access-Control-Allow-Origin", HeaderValue::from_static("*"));
    res.headers_mut()
        .insert("Content-Type", HeaderValue::from_static("application/json"));

    Ok(res)
}

static CFG: OnceLock<Config> = OnceLock::new();
pub fn cfg() -> &'static Config {
    CFG.get_or_init(|| {
        let path = env::var("HOMEPAGE_CONFIG_PATH").unwrap_or("config.json".into());

        let json = std::fs::read(&path).expect("Could not open config file");
        serde_json::from_slice(&json).expect("Could not parse config")
    })
}

#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let addr = SocketAddr::from(([127, 0, 0, 1], cfg().port));
    let listener = TcpListener::bind(addr).await?;

    loop {
        let (stream, _) = listener.accept().await?;
        let io = TokioIo::new(stream);

        tokio::task::spawn(async move {
            if let Err(err) = http1::Builder::new()
                .serve_connection(io, service_fn(route))
                .await
            {
                eprintln!("Error serving connection: {}", err);
            }
        });
    }
}
