use std::{fs::File, path::{Path, PathBuf}};

use clap::Parser;
use thiserror::Error;

use crate::config::Config;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Error, Debug)]
pub enum Error {
    #[error("I/O error {0}")]
    Io(#[from] std::io::Error),
    #[error("JSON error {0}")]
    Json(#[from] serde_json::Error)
}

#[derive(Parser)]
pub struct Opt {
    config_file: PathBuf,
    home_directory: PathBuf
}

fn read_config(file: &Path) -> Result<Config> {
    let file = File::open(file)?;
    let json: Config = serde_json::from_reader(file)?;
    Ok(json)
}

pub fn run(args: Opt) -> Result<()> {
    println!(
        "Installing mutable files to {} using config {}",
        args.home_directory.display(),
        args.config_file.display()
    );

    let config = read_config(&args.config_file)?;

    // See [[../../../docs/plan/activate-mutable.md]]
    // Having no active config is a valid state, documented as being identical to an empty config.
    let active_config = read_config(
        &args.home_directory.join(".config/activate-mutable-config.json")
    ).unwrap_or_else(|_| {
        println!("Active config not found. Treating as empty.");
        Config::new()
    });
    println!("{}", config.len());
    println!("{}", active_config.len());

    Ok(())
}
