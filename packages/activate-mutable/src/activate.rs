use std::fs::{exists, remove_file};
use std::os::unix::fs::symlink;
use std::path::{Path, PathBuf};

use clap::Parser;
use thiserror::Error;

use crate::state::{ExistingMatch, Files};

use crate::config::{
    Config, ConfigEntry, ConflictStrategy, find_entry, get_previous_config_path, read_config,
    resolve_directory,
};

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Error, Debug)]
pub enum Error {
    #[error(transparent)]
    Io(#[from] std::io::Error),
    #[error(transparent)]
    Json(#[from] serde_json::Error),
    #[error("File changed locally: {file}")]
    Conflict { file: PathBuf },
    #[error(transparent)]
    Config(#[from] crate::config::Error),
    #[error(transparent)]
    DirectoryTraversal(#[from] crate::config::DirectoryTraversalError),
}

#[derive(Parser)]
pub struct Opt {
    config_file: PathBuf,
    home_directory: PathBuf,

    /// Always overwrite local changes, even if `onConflict` says otherwise
    #[arg(short, long)]
    force: bool,
}

#[derive(Debug)]
enum MatchOutcome {
    DoNothing,
    Conflict,
    CopyNew,
}

impl MatchOutcome {
    // See flow chart in plan.
    fn from_contents(files: &Files, on_conflict: &ConflictStrategy) -> Self {
        match files.compare() {
            ExistingMatch::NotInHome => MatchOutcome::CopyNew,
            ExistingMatch::EqualOld => MatchOutcome::CopyNew,
            ExistingMatch::EqualNew => MatchOutcome::DoNothing,
            ExistingMatch::Conflict => match on_conflict {
                ConflictStrategy::Warn => MatchOutcome::Conflict,
                ConflictStrategy::Replace => MatchOutcome::CopyNew,
            },
        }
    }
}

fn process_entry(home: &Path, entry: &ConfigEntry, old_entry: Option<&ConfigEntry>) -> Result<()> {
    let destination = resolve_directory(home, &entry.destination)?;
    let files = Files::read(entry, old_entry, &destination)?;

    let state = MatchOutcome::from_contents(&files, &entry.on_conflict);
    match state {
        MatchOutcome::DoNothing => Ok(()),
        MatchOutcome::Conflict => Err(Error::Conflict {
            file: destination.to_path_buf(),
        }),
        MatchOutcome::CopyNew => {
            let dir = match destination.parent() {
                Some(dir) => dir,
                None => {
                    return Err(Error::Io(std::io::Error::new(
                        std::io::ErrorKind::NotFound,
                        "Parent directory not found",
                    )));
                }
            };
            std::fs::create_dir_all(dir)?;
            // This follows symlinks, meaning the target of a symlink is copied
            // rather than the link itself, even if it's a relative path and
            // a link would be OK.
            // This doesn't cause any issues when restoring files, as the same
            // is true for fs::write meaning the link target is updated.
            std::fs::copy(&entry.source, &destination)?;
            // Paths in the Nix store are always read-only, disable this
            let mut permissions = std::fs::metadata(&entry.source)?.permissions();
            permissions.set_readonly(false);
            std::fs::set_permissions(&destination, permissions)?;

            Ok(())
        }
    }
}

fn write_current_config(home: &Path, config_path: &Path) -> Result<()> {
    let path = get_previous_config_path(home);

    // Special case: If we are reactivating manually, the user will be using
    // $config_path on the CLI, don't overwrite a symlink with itself.
    if path == config_path {
        return Ok(());
    }

    if exists(&path)? {
        remove_file(&path)?;
    }
    symlink(config_path, &path)?;
    Ok(())
}

/// Run the activation process, copying files specified in the config to the home directory.
/// Returns true if any non-fatal errors occurred.
pub fn run(args: Opt) -> Result<bool> {
    println!(
        "Installing mutable files to {} using config {}",
        args.home_directory.display(),
        args.config_file.display()
    );

    let mut config = read_config(&args.config_file)?;

    // See [[../../../docs/plan/activate-mutable.md]]
    // Having no active config is a valid state, documented as being identical to an empty config.
    let active_config = read_config(&get_previous_config_path(&args.home_directory))
        .unwrap_or_else(|_| {
            println!("Active config not found. Treating as empty.");
            Config::new()
        });

    // Write current config after reading what was there previously
    write_current_config(&args.home_directory, &args.config_file)?;
    if args.force {
        for entry in config.iter_mut() {
            entry.on_conflict = ConflictStrategy::Replace;
        }
    }

    let mut any_errors = false;
    for entry in &config {
        let old_entry = find_entry(&active_config, &entry.destination);

        match process_entry(&args.home_directory, entry, old_entry) {
            Ok(()) => (),
            Err(e) => {
                eprintln!("Error applying {}: {}", entry.destination.display(), e);
                any_errors = true;
            }
        }
    }

    Ok(any_errors)
}
