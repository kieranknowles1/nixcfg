use std::path::{Path, PathBuf};

use clap::Parser;
use thiserror::Error;

use crate::config::{get_previous_config_path, read_config, ConfigEntry};

#[derive(Error, Debug)]
pub enum Error {
    #[error("Environment variable {0}")]
    Environ(#[from] std::env::VarError),
    #[error("Config error: {0}")]
    Config(#[from] crate::config::Error),
    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),
}

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Parser)]
pub struct Opt {
    /// Path to the home directory.
    /// Defaults to $HOME.
    #[clap(long)]
    home: Option<PathBuf>,
    /// Path to the repository.
    /// Defaults to $FLAKE.
    #[clap(long)]
    repo: Option<PathBuf>,
}

struct FinalOpt {
    home: PathBuf,
    repo: PathBuf,
}

fn or_environ(value: Option<PathBuf>, name: &str) -> Result<PathBuf> {
    match value {
        Some(value) => Ok(value),
        None => Ok(std::env::var(name)?.into()),
    }
}

impl FinalOpt {
    fn from(opt: Opt) -> Result<Self> {
        let home = or_environ(opt.home, "HOME")?;
        let repo = or_environ(opt.repo, "FLAKE")?;
        Ok(Self {
            home,
            repo,
        })
    }
}

fn restore_file(entry: &ConfigEntry, home_path: &Path, repo: &Path) -> Result<()> {
    let repo_path = repo.join(&entry.repo_path);
    println!("Restoring file {:?} to {:?}", home_path, repo_path);

    match std::fs::exists(&repo_path)? {
        true => {
            // Replace the repository file with the up-to-date home file.
            std::fs::copy(&home_path, &repo_path)?;
            Ok(())
        }
        // Don't let us restore files if they don't exist. Basic check against misconfiguration.
        false => Err(Error::Io(std::io::Error::new(
            std::io::ErrorKind::NotFound,
            "File not found in repository",
        ))),
    }
}

/// Restore files to the repository.
/// Like activate, returns true if any non-fatal errors occurred.
pub fn run(args: Opt) -> Result<bool> {
    let opt = FinalOpt::from(args)?;

    println!(
        "Restoring files from using $HOME={} and $FLAKE={}",
        opt.home.display(),
        opt.repo.display()
    );

    let config = read_config(&get_previous_config_path(&opt.home))?;

    for (name, entry) in config.iter() {
        let home_path = opt.home.join(name);
        restore_file(entry, &home_path, &opt.repo)?;
    }

    Ok(false)
}
