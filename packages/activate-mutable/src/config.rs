use std::path::{Path, PathBuf};

use serde::{Deserialize, Serialize};
use thiserror::Error;

#[derive(Debug, Error)]
pub enum Error {
    #[error("I/O error {0}")]
    Io(#[from] std::io::Error),
    #[error("JSON error {0}")]
    Json(#[from] serde_json::Error),
}

#[derive(Error, Debug)]
#[error("Directory traversal detected: {file}")]
pub struct DirectoryTraversalError {
    file: PathBuf,
}

pub type Result<T> = std::result::Result<T, Error>;

pub type Config = Vec<ConfigEntry>;

pub fn get_previous_config_path(home: &Path) -> PathBuf {
    home.join(".config/activate-mutable-config.json")
}

/// Return `value` if it is `Some`, otherwise use the value of the environment variable `name`.
pub fn or_environ(
    value: Option<PathBuf>,
    name: &str,
) -> std::result::Result<PathBuf, std::env::VarError> {
    match value {
        Some(value) => Ok(value),
        None => Ok(std::env::var(name)?.into()),
    }
}

pub fn read_config(file: &Path) -> Result<Config> {
    let file = std::fs::File::open(file)?;
    let json: Config = serde_json::from_reader(file)?;
    Ok(json)
}

pub fn find_entry<'a>(entries: &'a Config, path: &Path) -> Option<&'a ConfigEntry> {
    entries.iter().find(|entry| entry.destination == path)
}

fn is_subdirectory(parent: &Path, child: &Path) -> bool {
    child.ancestors().any(|ancestor| ancestor == parent)
}

/// Resolve a possibly absolute path, throwing if it is not a path in the home directory
pub fn resolve_directory(
    home: &Path,
    path: &Path,
) -> std::result::Result<PathBuf, DirectoryTraversalError> {
    let full = home.join(path);
    match is_subdirectory(home, &full) {
        true => Ok(full),
        false => Err(DirectoryTraversalError { file: full }),
    }
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(rename_all = "lowercase")]
pub enum ConflictStrategy {
    Replace,
    Warn,
}

#[derive(Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
#[serde(rename_all = "camelCase")]
pub struct ConfigEntry {
    /// Absolute path to the file, typically in the Nix store.
    pub source: PathBuf,
    /// Path of the file in the home directory.
    /// May be relative to the home directory or an absolute path that is in HOME.
    /// Absolute paths pointing outside of HOME will be rejected as a security measure.
    pub destination: PathBuf,
    /// What to do when the file has changed locally.
    pub on_conflict: ConflictStrategy,
    /// Path to the file in the repository, relative to the repository root.
    pub repo_path: Option<String>,
    /// Script to convert a deployed file to a repo file
    pub transformer: Option<PathBuf>,
}
