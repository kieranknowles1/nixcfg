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

#[derive(Serialize, Deserialize, Debug, PartialEq)]
pub struct Vec2 {
    pub x: f64,
    pub y: f64,
}

#[derive(Serialize, Deserialize, Debug, PartialEq)]
pub struct Vec3 {
    pub x: f64,
    pub y: f64,
    pub z: f64,
}

#[derive(Serialize, Deserialize, Debug, PartialEq)]
pub struct Color {
    pub r: f32,
    pub g: f32,
    pub b: f32,
    pub a: f32,
}

/// A value in the storage file. When serializing to JSON, values will be tagged with their type
/// to allow for round-tripping.
/// Serde handles all of this for us, and automagically generates code to serialize and deserialize
#[derive(Serialize, Deserialize, Debug, PartialEq)]
#[serde(untagged)]
pub enum Value {
    Number(f64),
    Boolean(bool),
    String(String),
    Table(Table),
    Array(Array),
    // OpenMW-specific types
    Vec2(Vec2),
    Vec3(Vec3),
    Color(Color),
}
