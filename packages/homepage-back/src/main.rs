use std::net::SocketAddr;
use std::sync::OnceLock;

use clap::Parser;
use http_body_util::Full;
use hyper::body::Bytes;
use hyper::header::HeaderValue;
use hyper::server::conn::http1;
use hyper::service::service_fn;
use hyper::{Request, Response, StatusCode};
use hyper_util::rt::TokioIo;
use tokio::net::TcpListener;

mod stats;

#[derive(clap::Parser)]
struct Cli {
    #[clap(long, env = "HOMEPAGE_PORT", default_value = "4321")]
    port: u16,

    #[clap(flatten)]
    sysinfo: SysInfoOpts,

    #[clap(flatten)]
    trilium: TriliumOpts,
}

#[derive(clap::Args)]
struct SysInfoOpts {
    #[clap(
        name = "enable-sysinfo",
        long,
        env = "HOMEPAGE_SYSINFO_ENABLE",
        default_value = "false"
    )]
    enable: bool,
}

#[derive(clap::Args)]
#[group(required = false)]
struct TriliumOpts {
    #[clap(
        name = "enable-trilium",
        long,
        env = "HOMEPAGE_TRILIUM_ENABLE",
        default_value = "false",
        requires = "url",
        requires = "api_file"
    )]
    enable: bool,

    /// Base URL for Trilium
    #[clap(long = "trilium-url", env = "HOMEPAGE_TRILIUM_URL")]
    url: Option<String>,

    /// File containing an ETAPI key for Trilium
    #[clap(long = "trilium-api-file", env = "HOMEPAGE_TRILIUM_API_FILE")]
    api_file: Option<String>,
}

static CLI: OnceLock<Cli> = OnceLock::new();
fn cli() -> &'static Cli {
    CLI.get_or_init(|| Cli::parse())
}

async fn route(
    req: Request<hyper::body::Incoming>,
) -> Result<Response<Full<Bytes>>, serde_json::Error> {
    let mut res = match req.uri().path() {
        "/info" => stats::info_route(req).await,
        "/metrics" => stats::route(req).await,
        _ => {
            let mut res = Response::new(Full::new(Bytes::from("Not Found")));
            *res.status_mut() = StatusCode::NOT_FOUND;
            Ok(res)
        }
    }?;

    // TODO: This may only be needed for development
    res.headers_mut()
        .insert("Access-Control-Allow-Origin", HeaderValue::from_static("*"));
    res.headers_mut()
        .insert("Content-Type", HeaderValue::from_static("application/json"));
    Ok(res)
}

// This is expected to be a low-demand service, so run everything on the
// main thread
#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Listen on port 4321
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
