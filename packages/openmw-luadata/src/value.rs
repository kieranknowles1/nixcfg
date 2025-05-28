use std::collections::BTreeMap;

use serde::{Deserialize, Serialize};

pub type Table = BTreeMap<String, Value>;
// Technically, Lua doesn't have arrays, it uses tables with integer keys
// However, JSON objects (used to store tables here) only support string keys
// We handle this edge case by storing as an array, which is good enough for now
// but not all encompasing. Cases not handled include:
// - Table with both integer and string keys
// - Table with non integer or string keys
// - Sparse arrays
// - Arrays that start from 0
// - Float keys (please don't do that)
pub type Array = Vec<Value>;

/// A value in the storage file. When serializing to JSON, values will be tagged with their type
/// to allow for round-tripping.
/// Serde handles all of this for us, and automagically generates code to serialize and deserialize
#[derive(Serialize, Deserialize, Debug)]
pub enum Value {
    Number(f64),
    Boolean(bool),
    String(String),
    Table(Table),
    Array(Array),

    // OpenMW-specific types
    Vec2(f64, f64),
}

impl PartialEq for Value {
    fn eq(&self, other: &Self) -> bool {
        match (self, other) {
            (Value::Number(a), Value::Number(b)) => a == b,
            (Value::Boolean(a), Value::Boolean(b)) => a == b,
            (Value::String(a), Value::String(b)) => a == b,
            (Value::Table(a), Value::Table(b)) => a == b,
            (Value::Array(a), Value::Array(b)) => a == b,
            (Value::Vec2(a1, a2), Value::Vec2(b1, b2)) => a1 == b1 && a2 == b2,
            _ => false,
        }
    }
}

impl Eq for Value {}
