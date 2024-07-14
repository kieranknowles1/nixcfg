use std::{collections::{HashMap, HashSet}, path::{Path, PathBuf, StripPrefixError}};
use serde::Deserialize;

#[derive(Deserialize)]
pub struct Config {
    /// Editor to use for opening files
    pub editor: String,
    /// Path to the nixcfg repository on disk
    pub repository: PathBuf,

    /// Programs that can be configured, with keys being the program name
    /// and values being their config data
    pub programs: HashMap<String, ProgramConfig>,
}

#[derive(Deserialize)]
pub struct ProgramConfig {
    /// List of paths to ignore. If a directory is ignored, all files
    /// within it are ignored as well.
    #[serde(rename = "ignore-paths")]
    ignore_paths: HashSet<String>,

    #[serde(rename = "repo-path")]
    repo_path: String,

    #[serde(rename = "system-path")]
    system_path: String,
}

/// Program config with absolute paths instead of possibly relative paths
#[derive(Debug)]
pub struct AbsoluteProgramConfig {
    pub ignore_paths: HashSet<PathBuf>,
    pub repo_path: PathBuf,
    pub system_path: PathBuf,
}

impl ProgramConfig {
    pub fn to_absolute(&self, repository: &Path) -> AbsoluteProgramConfig {
        let expanded_system_path = shellexpand::tilde(&self.system_path);
        let system_path = PathBuf::from(expanded_system_path.into_owned());

        AbsoluteProgramConfig {
            ignore_paths: self.ignore_paths.iter().map(|p| system_path.join(p)).collect(),
            repo_path: repository.join(&self.repo_path),
            system_path,
        }
    }
}

impl AbsoluteProgramConfig {
    /// Check if a path in system_path is ignored
    pub fn is_ignored(&self, path: &Path) -> bool {
        // starts_with also counts if the path is identical
        self.ignore_paths.iter().any(|p| path.starts_with(p))
    }

    /// Convert a path in system_path to a path in repo_path
    pub fn to_repo_path(&self, path: &Path) -> Result<PathBuf, StripPrefixError> {
        let stripped = path.strip_prefix(&self.system_path)?;
        Ok(self.repo_path.join(stripped))
    }
}

impl Config {
    pub fn from_str(s: &str) -> Result<Self, serde_json::Error> {
        serde_json::from_str(s)
    }
}
