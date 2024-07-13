use std::collections::HashMap;
use serde::Deserialize;

#[derive(Deserialize)]
pub struct Config {
    /// Editor to use for opening files
    pub editor: String,
    /// Path to the nixcfg repository on disk
    pub repository: String,

    /// Programs that can be configured, with keys being the program name
    /// and values being their config data
    pub programs: HashMap<String, ProgramConfig>,
}

#[derive(Deserialize)]
pub struct ProgramConfig {
    /// List of paths to ignore. If a directory is ignored, all files
    /// within it are ignored as well.
    #[serde(rename = "ignore-paths")]
    pub ignore_paths: Vec<String>,

    #[serde(rename = "repo-path")]
    pub repo_path: String,

    #[serde(rename = "system-path")]
    pub system_path: String,
}

impl Config {
    pub fn from_str(s: &str) -> Result<Self, serde_json::Error> {
        serde_json::from_str(s)
    }
}
