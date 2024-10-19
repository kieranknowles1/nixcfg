use std::collections::BTreeMap;
use std::path::PathBuf;

use serde::{Deserialize, Serialize};

// use a BTreeMap to keep the order predictable
pub type Config = BTreeMap<PathBuf, ConfigEntry>;

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum ConflictStrategy {
    Replace,
    Warn,
}

#[derive(Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ConfigEntry {
    pub source: PathBuf,
    #[serde(rename = "onConflict")]
    pub on_conflict: ConflictStrategy,
}
