use std::{fs::File, path::{Path, PathBuf}};

use clap::Parser;
use thiserror::Error;
use sha2::{Digest, Sha256};

use crate::config::{Config, ConfigEntry, ConflictStrategy};

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Error, Debug)]
pub enum Error {
    #[error("I/O error {0}")]
    Io(#[from] std::io::Error),
    #[error("JSON error {0}")]
    Json(#[from] serde_json::Error),
    #[error("File changed locally: {file}")]
    Conflict { file: PathBuf },
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

type Hash = [u8; 32];

#[derive(Debug)]
enum MatchOutcome {
    DoNothing,
    Conflict,
    CopyNew
}

enum ExistingMatch {
    EqualNew,
    EqualOld,
    NotInOld,
    Conflict
}

impl MatchOutcome {
    // See flow chart in plan.
    fn from_hashes(
        old_hash: Option<Hash>,
        new_hash: Hash, // If this wasn't present, we're not touching the file.
        home_hash: Option<Hash>,
        on_conflict: &ConflictStrategy
    ) -> Self {
        if let Some(home) = home_hash {
            let status = ExistingMatch::from_hashes(old_hash, new_hash, home);
            match status {
                ExistingMatch::EqualNew => MatchOutcome::DoNothing,
                ExistingMatch::EqualOld => MatchOutcome::CopyNew,
                ExistingMatch::Conflict | ExistingMatch::NotInOld => {
                    match on_conflict {
                        ConflictStrategy::Warn => MatchOutcome::Conflict,
                        ConflictStrategy::Replace => MatchOutcome::CopyNew
                    }
                }
            }
        }
        // If the file isn't in $HOME, always copy the new file.
        else { MatchOutcome::CopyNew }
    }
}

impl ExistingMatch {
    // Compare existing, previous, and new files to determine what to do.
    fn from_hashes(
        old_hash: Option<Hash>,
        new_hash: Hash,
        home_hash: Hash,
    ) -> Self {
        match old_hash {
            None => ExistingMatch::NotInOld,
            Some(old) => {
                if new_hash == home_hash {
                    ExistingMatch::EqualNew
                } else if old == home_hash {
                    ExistingMatch::EqualOld
                } else {
                    ExistingMatch::Conflict
                }
            }
        }
    }
}

fn hash_file(path: &Path) -> Result<Hash> {
    let data = std::fs::read(path)?;
    let digest = Sha256::digest(&data);
    Ok(digest.into())
}

fn apply_file(
    path: &Path,
    entry: &ConfigEntry,
    old_entry: Option<&ConfigEntry>,
) -> Result<()> {
    println!("Applying {}", path.display());

    let new_hash = hash_file(&entry.source)?;
    let old_hash = match old_entry {
        Some(old) => Some(hash_file(&old.source)?),
        None => None
    };
    let home_hash = hash_file(path).ok();

    let state = MatchOutcome::from_hashes(old_hash, new_hash, home_hash, &entry.on_conflict);
    println!("State: {:?}", state);
    match state {
        MatchOutcome::DoNothing => {
            println!("No changes needed.");
            Ok(())
        }
        MatchOutcome::Conflict => {
            Err(Error::Conflict { file: path.to_path_buf() })
        },
        MatchOutcome::CopyNew => {
            let dir = match path.parent() {
                Some(dir) => dir,
                None => return Err(Error::Io(std::io::Error::new(
                    std::io::ErrorKind::NotFound,
                    "Parent directory not found"
                )))
            };
            std::fs::create_dir_all(&dir)?;
            std::fs::copy(&entry.source, path)?;
            Ok(())
        }
    }
}

fn get_previous_config_path(home: &Path) -> PathBuf {
    home.join(".config/activate-mutable-config.json")
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

    let config = read_config(&args.config_file)?;

    // See [[../../../docs/plan/activate-mutable.md]]
    // Having no active config is a valid state, documented as being identical to an empty config.
    let active_config = read_config(
        &get_previous_config_path(&args.home_directory)
    ).unwrap_or_else(|_| {
        println!("Active config not found. Treating as empty.");
        Config::new()
    });

    let mut any_errors = false;
    for (name, entry) in config.iter() {
        let old_entry = active_config.get(name);
        let full_path = args.home_directory.join(name);
        match apply_file(&full_path, entry, old_entry) {
            Ok(()) => (),
            Err(e) => {
                eprintln!("Error applying {}: {}", name.display(), e);
                any_errors = true;
            }
        }
    }

    write_previous_config(&args.home_directory, &config)?;

    Ok(any_errors)
}
