use std::{collections::HashMap, path::PathBuf};

use serde::{Deserialize, Serialize};

pub type Config = HashMap<PathBuf, ConfigEntry>;

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
    pub on_conflict: ConflictStrategy,
}
