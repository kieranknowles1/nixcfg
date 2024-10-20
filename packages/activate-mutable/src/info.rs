use std::path::PathBuf;

use clap::Parser;
use thiserror::Error;

use crate::config::{get_previous_config_path, or_environ, read_config};

#[derive(Error, Debug)]
pub enum Error {
    #[error("Environment variable {0}")]
    Environ(#[from] std::env::VarError),
    #[error("Config error: {0}")]
    Config(#[from] crate::config::Error),
}

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Parser)]
pub struct Opt {
    #[clap(long)]
    home: Option<PathBuf>,
}

pub fn run(args: Opt) -> Result<()> {
    let home = or_environ(args.home, "HOME")?;
    let config = read_config(&get_previous_config_path(&home))?;

    for (path, entry) in config {
        let repo = match entry.repo_path {
            Some(repo) => repo,
            None => "<no repo path>".to_string(),
        };
        println!("{}", path.display());
        println!("  Repository: {}", repo);
        println!("  On conflict: {:?}", entry.on_conflict);
    }

    Ok(())
}
