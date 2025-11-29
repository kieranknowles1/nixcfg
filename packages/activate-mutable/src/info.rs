use std::path::PathBuf;

use clap::Parser;
use colored::{ColoredString, Colorize};
use thiserror::Error;

use crate::{
    config::{ConflictStrategy, get_previous_config_path, read_config, resolve_directory},
    state::{ExistingMatch, Files},
};

#[derive(Error, Debug)]
pub enum Error {
    #[error(transparent)]
    Config(#[from] crate::config::Error),
    #[error(transparent)]
    DirectoryTraversal(#[from] crate::config::DirectoryTraversalError),
    #[error(transparent)]
    Io(#[from] std::io::Error),
}

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Parser)]
pub struct Opt {
    #[clap(long, env)]
    home: PathBuf,
}

fn describe_status(status: ExistingMatch) -> ColoredString {
    match status {
        ExistingMatch::EqualNew => "Not changed".cyan(),
        ExistingMatch::Conflict => "Changed".red(),
        ExistingMatch::NotInHome => "Not deployed".red(),
        ExistingMatch::EqualOld => panic!("No old hash was passed, how did thi hapen?"),
    }
}

/// Show info about the current deployed state
/// Now with colour!
///     Bold: Section
///     Cyan: Ok
///     Yellow: Be careful
///     Red: Error
pub fn run(args: &Opt) -> Result<()> {
    let config = read_config(&get_previous_config_path(&args.home))?;

    let mut base_dir = None;
    for entry in &config {
        if entry.base_destination.as_ref() != base_dir {
            base_dir = entry.base_destination.as_ref();
            if let Some(base_dir) = &base_dir {
                println!("{}", base_dir.to_string_lossy().bold());
            }
        }

        let repo = match &entry.repo_path {
            Some(repo) => repo.normal(),
            None => "<no repo path>".yellow(),
        };
        let on_conflict = match entry.on_conflict {
            ConflictStrategy::Warn => "Warn".cyan(),
            ConflictStrategy::Replace => "Replace".yellow(),
        };

        let destination = resolve_directory(&args.home, &entry.destination)?;
        let files = Files::read(entry, None, &destination)?;

        let prefix_spoke = if base_dir.is_none() { "" } else { "├──" };
        let prefix_line = if base_dir.is_none() { "" } else { "│   " };

        println!(
            "{prefix_spoke}{}",
            entry.destination.to_string_lossy().bold()
        );
        println!("{prefix_line}  Repository: {repo}");
        println!("{prefix_line}  On conflict: {on_conflict}");
        println!(
            "{prefix_line}  Status: {}",
            describe_status(files.compare())
        );
    }

    Ok(())
}
