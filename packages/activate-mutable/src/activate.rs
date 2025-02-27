use std::fs::File;
use std::path::{Path, PathBuf};

use clap::Parser;
use thiserror::Error;

use crate::state::{hash_file, ExistingMatch, Hash};

use crate::config::{
    find_entry, get_previous_config_path, read_config, resolve_directory, Config, ConfigEntry,
    ConflictStrategy,
};

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Error, Debug)]
pub enum Error {
    #[error("I/O error {0}")]
    Io(#[from] std::io::Error),
    #[error("JSON error {0}")]
    Json(#[from] serde_json::Error),
    #[error("File changed locally: {file}")]
    Conflict { file: PathBuf },
    #[error("Error loading config: {0}")]
    Config(#[from] crate::config::Error),
    #[error("Directory traversal")]
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
    fn from_hashes(
        old_hash: Option<Hash>,
        new_hash: Hash, // If this wasn't present, we wouldn't be provisioning it.
        home_hash: Option<Hash>,
        on_conflict: &ConflictStrategy,
    ) -> Self {
        if let Some(home) = home_hash {
            let status = ExistingMatch::from_hashes(old_hash, new_hash, home);
            match status {
                ExistingMatch::EqualNew => MatchOutcome::DoNothing,
                ExistingMatch::EqualOld => MatchOutcome::CopyNew,
                ExistingMatch::Conflict => match on_conflict {
                    ConflictStrategy::Warn => MatchOutcome::Conflict,
                    ConflictStrategy::Replace => MatchOutcome::CopyNew,
                },
            }
        }
        // If the file isn't in $HOME, always copy the new file.
        else {
            MatchOutcome::CopyNew
        }
    }
}

fn copy_file(path: &Path, entry: &ConfigEntry, old_entry: Option<&ConfigEntry>) -> Result<()> {
    let new_hash = hash_file(&entry.source)?;
    let old_hash = match old_entry {
        Some(old) => Some(hash_file(&old.source)?),
        None => None,
    };
    let home_hash = hash_file(path).ok();

    let state = MatchOutcome::from_hashes(old_hash, new_hash, home_hash, &entry.on_conflict);
    match state {
        MatchOutcome::DoNothing => Ok(()),
        MatchOutcome::Conflict => Err(Error::Conflict {
            file: path.to_path_buf(),
        }),
        MatchOutcome::CopyNew => {
            let dir = match path.parent() {
                Some(dir) => dir,
                None => {
                    return Err(Error::Io(std::io::Error::new(
                        std::io::ErrorKind::NotFound,
                        "Parent directory not found",
                    )))
                }
            };
            std::fs::create_dir_all(&dir)?;
            std::fs::copy(&entry.source, path)?;
            // Paths in the Nix store are always read-only, disable this
            let mut permissions = std::fs::metadata(&entry.source)?.permissions();
            permissions.set_readonly(false);
            std::fs::set_permissions(path, permissions)?;

            Ok(())
        }
    }
}

fn process_entry(home: &Path, entry: &ConfigEntry, old_entry: Option<&ConfigEntry>) -> Result<()> {
    let full_path = resolve_directory(home, &entry.destination)?;
    copy_file(&full_path, entry, old_entry)
}

fn write_previous_config(home: &Path, config: &Config) -> Result<()> {
    let path = get_previous_config_path(home);
    let file = File::create(path)?;
    serde_json::to_writer(file, config)?;
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
    if args.force {
        for entry in config.iter_mut() {
            entry.on_conflict = ConflictStrategy::Replace;
        }
    }

    // See [[../../../docs/plan/activate-mutable.md]]
    // Having no active config is a valid state, documented as being identical to an empty config.
    let active_config = read_config(&get_previous_config_path(&args.home_directory))
        .unwrap_or_else(|_| {
            println!("Active config not found. Treating as empty.");
            Config::new()
        });

    let mut any_errors = false;
    for entry in &config {
        let old_entry = find_entry(&active_config, &entry.destination);

        match process_entry(&args.home_directory, &entry, old_entry) {
            Ok(()) => (),
            Err(e) => {
                eprintln!("Error applying {}: {}", entry.destination.display(), e);
                any_errors = true;
            }
        }
    }

    write_previous_config(&args.home_directory, &config)?;

    Ok(any_errors)
}
