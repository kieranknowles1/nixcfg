use std::path::PathBuf;

use serde::Deserialize;

pub type Config = Vec<ConfigEntry>;

#[derive(Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum ConflictStrategy {
    Replace,
    Warn,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ConfigEntry {
    destination: String,
    source: PathBuf,
    on_conflict: ConflictStrategy,
}
