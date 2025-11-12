use std::net::SocketAddr;
use std::sync::OnceLock;

use clap::Parser;
use http_body_util::Full;
use hyper::body::Bytes;
use hyper::server::conn::http1;
use hyper::service::service_fn;
use hyper::{Request, Response, StatusCode};
use hyper_util::rt::TokioIo;
use tokio::net::TcpListener;

mod stats;

#[derive(clap::Parser)]
struct Cli {
    #[clap(long, env = "HOMEPAGE_PORT", default_value = "3000")]
    port: u16,
}

static CLI: OnceLock<Cli> = OnceLock::new();
fn cli() -> &'static Cli {
    CLI.get_or_init(|| Cli::parse())
}

async fn route(
    req: Request<hyper::body::Incoming>,
) -> Result<Response<Full<Bytes>>, serde_json::Error> {
    match req.uri().path() {
        "/" => stats::route(req).await,
        _ => {
            let mut res = Response::new(Full::new(Bytes::from("Not Found")));
            *res.status_mut() = StatusCode::NOT_FOUND;
            Ok(res)
        }
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Listen on port 3000
    let addr = SocketAddr::from(([127, 0, 0, 1], cli().port));
    let listener = TcpListener::bind(addr).await?;

    // Listen for incoming connections indefinitely
    loop {
        let (stream, _) = listener.accept().await?;

        let io = TokioIo::new(stream);

        // Handle connections in a separate task, which may be its own thread
        tokio::task::spawn(async move {
            if let Err(err) = http1::Builder::new()
                .serve_connection(io, service_fn(route))
                .await
            {
                eprintln!("Error serving connection: {:?}", err);
            }
        });
    }
}
