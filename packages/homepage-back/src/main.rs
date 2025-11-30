use std::{convert::Infallible, net::SocketAddr};

use http_body_util::Full;
use hyper::{Request, Response, body::Bytes, server::conn::http1, service::service_fn};
use hyper_util::rt::TokioIo;
use tokio::net::TcpListener;

#[derive(serde::Deserialize)]
#[serde(deny_unknown_fields)]
struct Config {
    #[serde(default = "default_port")]
    port: u16,
}

fn default_port() -> u16 {
    8080
}

async fn route(_: Request<hyper::body::Incoming>) -> Result<Response<Full<Bytes>>, Infallible> {
    Ok(Response::new(Full::new(Bytes::from("Hello, World!"))))
}

#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cfg = std::fs::read("config.json").unwrap_or("{}".into());
    let cfg: Config = serde_json::from_slice(&cfg)?;

    let addr = SocketAddr::from(([127, 0, 0, 1], cfg.port));
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
