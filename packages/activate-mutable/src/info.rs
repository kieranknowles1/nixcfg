use std::path::{Path, PathBuf};

use clap::Parser;
use colored::{ColoredString, Colorize};
use thiserror::Error;

use crate::{
    config::{
        get_previous_config_path, or_environ, read_config, resolve_directory, ConflictStrategy,
    },
    state::{hash_file, ExistingMatch},
};

#[derive(Error, Debug)]
pub enum Error {
    #[error("Environment variable {0}")]
    Environ(#[from] std::env::VarError),
    #[error("Config error: {0}")]
    Config(#[from] crate::config::Error),
    #[error("Directory traversal")]
    DirectoryTraversal(#[from] crate::config::DirectoryTraversalError),
    #[error("IO Error")]
    Io(#[from] std::io::Error),
}

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Parser)]
pub struct Opt {
    #[clap(long)]
    home: Option<PathBuf>,
}

fn get_status(home: &Path, store_path: &Path, home_path: &Path) -> Option<ColoredString> {
    let store_hash = hash_file(&store_path).ok()?;
    let full_home = resolve_directory(home, home_path).ok()?;
    let home_hash = hash_file(&full_home).ok()?;

    match ExistingMatch::from_hashes(None, store_hash, home_hash) {
        ExistingMatch::EqualNew => Some("Not changed".cyan()),
        ExistingMatch::Conflict => Some("Changed".red()),
        ExistingMatch::EqualOld => panic!("No old hash was passed, how did thi hapen?"),
    }
}

/// Show info about the current deployed state
/// Now with colour!
///     Bold: Section
///     Cyan: Ok
///     Yellow: Be careful
///     Red: Error
pub fn run(args: Opt) -> Result<()> {
    let home = or_environ(args.home, "HOME")?;
    let config = read_config(&get_previous_config_path(&home))?;

    for entry in &config {
        let repo = match &entry.repo_path {
            Some(repo) => repo.normal(),
            None => "<no repo path>".yellow(),
        };
        let on_conflict = match entry.on_conflict {
            ConflictStrategy::Warn => "Warn".cyan(),
            ConflictStrategy::Replace => "Replace".yellow(),
        };
        let status =
            get_status(&home, &entry.source, &entry.destination).unwrap_or("Unknown".red());

        println!("{}", entry.destination.to_string_lossy().bold());
        println!("  Repository: {}", repo);
        println!("  On conflict: {}", on_conflict);
        println!("  Status: {}", status);
    }

    Ok(())
}
