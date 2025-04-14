use std::path::{Path, PathBuf};

use clap::Parser;
use thiserror::Error;

use crate::config::{get_previous_config_path, or_environ, read_config};

#[derive(Error, Debug)]
pub enum Error {
    #[error(transparent)]
    Environ(#[from] std::env::VarError),
    #[error(transparent)]
    Config(#[from] crate::config::Error),
    #[error(transparent)]
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

impl FinalOpt {
    fn from(opt: Opt) -> Result<Self> {
        let home = or_environ(opt.home, "HOME")?;
        let repo = or_environ(opt.repo, "FLAKE")?;
        Ok(Self { home, repo })
    }
}

fn restore_file(repo_path: &Path, home_path: &Path) -> Result<()> {
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
pub fn run(args: Opt) -> Result<()> {
    let opt = FinalOpt::from(args)?;

    println!(
        "Restoring files using $HOME={} and $FLAKE={}",
        opt.home.display(),
        opt.repo.display()
    );

    let config = read_config(&get_previous_config_path(&opt.home))?;

    for entry in &config {
        let home_path = opt.home.join(&entry.destination);
        match &entry.repo_path {
            Some(repo_relative) => {
                let full_repo = opt.repo.join(repo_relative);
                restore_file(&full_repo, &home_path)?;
            }
            None => {
                eprintln!(
                    "No repository path specified for {:?}, cannot restore",
                    home_path
                );
            }
        };
    }

    Ok(())
}
