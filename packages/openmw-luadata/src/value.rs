use std::{cmp::Ordering, collections::BTreeMap};

use serde::{Deserialize, Serialize};

pub type Table = BTreeMap<Value, Value>;

#[derive(Serialize, Deserialize, Debug, PartialEq, PartialOrd)]
pub struct Vec2 {
    pub x: f64,
    pub y: f64,
}

#[derive(Serialize, Deserialize, Debug, PartialEq, PartialOrd)]
pub struct Vec3 {
    pub x: f64,
    pub y: f64,
    pub z: f64,
}

#[derive(Serialize, Deserialize, Debug, PartialEq, PartialOrd)]
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
pub enum Value {
    Number(f64),
    Boolean(bool),
    String(String),
    Table(Table),
    // OpenMW-specific types
    Vec2(Vec2),
    Vec3(Vec3),
    Color(Color),
}

// UNSAFE: We don't handle NaN or Infinity
impl Eq for Value {}

impl Ord for Value {
    fn cmp(&self, other: &Self) -> Ordering {
        match (self, other) {
            (Value::Number(a), Value::Number(b)) => a.partial_cmp(b).unwrap(),
            (Value::Boolean(a), Value::Boolean(b)) => a.cmp(b),
            (Value::String(a), Value::String(b)) => a.cmp(b),
            (Value::Table(a), Value::Table(b)) => a.partial_cmp(b).unwrap(),
            (Value::Vec2(a), Value::Vec2(b)) => a.partial_cmp(b).unwrap(),
            (Value::Vec3(a), Value::Vec3(b)) => a.partial_cmp(b).unwrap(),
            (Value::Color(a), Value::Color(b)) => a.partial_cmp(b).unwrap(),
            _ => panic!("Cannot compare different types"),
        }
    }
}

impl PartialOrd for Value {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}
