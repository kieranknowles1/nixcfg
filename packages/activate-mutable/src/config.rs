use std::collections::BTreeMap;
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

pub type Result<T> = std::result::Result<T, Error>;

// use a BTreeMap to keep the order predictable
pub type Config = BTreeMap<PathBuf, ConfigEntry>;

pub fn get_previous_config_path(home: &Path) -> PathBuf {
    home.join(".config/activate-mutable-config.json")
}

pub fn read_config(file: &Path) -> Result<Config> {
    let file = std::fs::File::open(file)?;
    let json: Config = serde_json::from_reader(file)?;
    Ok(json)
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum ConflictStrategy {
    Replace,
    Warn,
}

#[derive(Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
#[serde(rename_all = "camelCase")]
pub struct ConfigEntry {
    // Absolute path to the file, typically in the Nix store.
    pub source: PathBuf,
    // What to do when the file has changed locally.
    pub on_conflict: ConflictStrategy,
    // Path to the file in the repository, relative to the repository root.
    // TODO: Should this be required?
    pub repo_path: Option<String>,
}
