use std::collections::BTreeMap;

use serde::{Deserialize, Serialize};

pub type Table = BTreeMap<String, Value>;

/// A value in the storage file. When serializing to JSON, values will be tagged with their type
/// to allow for round-tripping.
/// Serde handles all of this for us, and automagically generates code to serialize and deserialize
#[derive(Serialize, Deserialize)]
#[derive(Debug)]
pub enum Value {
    Number(f64),
    Boolean(bool),
    String(String),
    Table(Table),

    // OpenMW-specific types
    Vec2(f64, f64),
}
