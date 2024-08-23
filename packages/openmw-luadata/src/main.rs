mod reader;

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
}

type Result<T> = std::result::Result<T, Error>;

fn main() -> Result<()> {
    let opt = Opt::parse();
    match opt {
        Opt::Decode { file } => {
            let data = reader::decode(&file)?;

            // TODO: Print the data in a machine-readable format
            // JSON is the obvious choice, but only supports string keys, while lua tables
            // can have anything but nil as a key
            println!("{:?}", data);
        }
        Opt::Encode { file } => {
            todo!("Encoding file: {}", file);
        }
    }

    Ok(())
}
