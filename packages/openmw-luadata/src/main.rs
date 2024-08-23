mod reader;
mod value;

use clap::Parser;
use thiserror::Error;

#[derive(Parser)]
enum Opt {
    Decode {
        file: String,
    },
    Encode {
        file: String,
    },
}

#[derive(Debug, Error)]
enum Error {
    #[error(transparent)]
    Decode(#[from] reader::Error),
    #[error(transparent)]
    Json(#[from] serde_json::Error),
}

type Result<T> = std::result::Result<T, Error>;

fn main() -> Result<()> {
    let opt = Opt::parse();
    match opt {
        Opt::Decode { file } => {
            let data = reader::decode(&file)?;

            let json = serde_json::to_string_pretty(&data)?;

            println!("{}", json);
        }
        Opt::Encode { file } => {
            todo!("Encoding file: {}", file);
        }
    }

    Ok(())
}
