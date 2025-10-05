use std::path::{Path, PathBuf};

use clap::Parser;
use thiserror::Error;

use crate::{
    config::{DirectoryTraversalError, get_previous_config_path, read_config, resolve_directory},
    state::Files,
};

#[derive(Error, Debug)]
pub enum Error {
    #[error(transparent)]
    Config(#[from] crate::config::Error),
    #[error(transparent)]
    Io(#[from] std::io::Error),
    #[error(transparent)]
    DirectoryTraversal(#[from] DirectoryTraversalError),
}

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Parser)]
pub struct Opt {
    /// Path to the home directory.
    #[clap(long, env)]
    home: PathBuf,
    /// Path to the repository.
    #[clap(long, env = "FLAKE")]
    repo: PathBuf,
}

fn restore_file(repo_path: &Path, home_path: &Path, transformer: Option<&Path>) -> Result<()> {
    println!("Restoring file {:?} to {:?}", home_path, repo_path);

    match std::fs::exists(&repo_path)? {
        true => {
            // Replace the repository file with the up-to-date home file.
            let contents = Files::read_transformed(home_path, transformer)?;
            // This follows symlinks, meaning the link target will be updated
            // rather than replacing the link itself.
            std::fs::write(repo_path, contents)?;

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
    println!(
        "Restoring files using $HOME={} and $FLAKE={}",
        args.home.display(),
        args.repo.display()
    );

    let config = read_config(&get_previous_config_path(&args.home))?;

    for entry in &config {
        let home = resolve_directory(&args.home, &entry.destination)?;
        match &entry.repo_path {
            Some(repo_relative) => {
                let full_repo = args.repo.join(repo_relative);
                restore_file(&full_repo, &home, entry.transformer.as_deref())?;
            }
            None => {
                eprintln!(
                    "No repository path specified for {:?}, cannot restore",
                    home
                );
            }
        };
    }

    Ok(())
}
