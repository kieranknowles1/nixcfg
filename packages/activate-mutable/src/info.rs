use std::path::PathBuf;

use clap::Parser;
use colored::{ColoredString, Colorize};
use thiserror::Error;

use crate::{
    config::{
        ConflictStrategy, get_previous_config_path, or_environ, read_config, resolve_directory,
    },
    state::{ExistingMatch, Files},
};

#[derive(Error, Debug)]
pub enum Error {
    #[error(transparent)]
    Environ(#[from] std::env::VarError),
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
    #[clap(long)]
    home: Option<PathBuf>,
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
pub fn run(args: Opt) -> Result<()> {
    let home = or_environ(args.home, "HOME")?;
    let config = read_config(&get_previous_config_path(&home))?;

    let mut base_dir = None;
    for entry in &config {
        if entry.base_destination != base_dir {
            base_dir = entry.base_destination.clone();
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

        let destination = resolve_directory(&home, &entry.destination)?;
        let files = Files::read(entry, None, &destination)?;

        let prefix_spoke = if base_dir == None { "" } else { "├──" };
        let prefix_line = if base_dir == None { "" } else { "│   " };

        println!(
            "{}{}",
            prefix_spoke,
            entry.destination.to_string_lossy().bold()
        );
        println!("{}  Repository: {}", prefix_line, repo);
        println!("{}  On conflict: {}", prefix_line, on_conflict);
        println!(
            "{}  Status: {}",
            prefix_line,
            describe_status(files.compare())
        );
    }

    Ok(())
}
