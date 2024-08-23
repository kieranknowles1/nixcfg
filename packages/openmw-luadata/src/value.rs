use std::collections::BTreeMap;

use ordered_float::OrderedFloat;
use serde::{Deserialize, Serialize};

// We use a btree instead of a hashmap to ensure that the keys are sorted
// This results in predictable ordering
// NOTE: If a table uses another table as a key, ordering will probably be weird anyway
// But if you do that, you're weird
pub type Table = BTreeMap<String, Value>;

fn deserialize_ordered_float<'de, D>(deserializer: D) -> Result<OrderedFloat<f64>, D::Error>
where
    D: serde::Deserializer<'de>,
{
    let f: f64 = Deserialize::deserialize(deserializer)?;
    Ok(OrderedFloat(f))
}

/// A value in the storage file
#[derive(Eq, PartialEq, Ord, PartialOrd)]
#[derive(Serialize, Deserialize)]
pub enum Value {
    // Rust doesn't let us have ordered floats, as NaN causes ambiguity. We instead use the
    // OrderedFloat crate which wraps a f64 to implement the Ord trait
    #[serde(serialize_with = "f64::serialize", deserialize_with = "deserialize_ordered_float")]
    Number(OrderedFloat<f64>),
    Boolean(bool),
    String(String),
    Table(Table),

    // OpenMW-specific types
    // These are not lua types, but instead userdata types that OpenMW uses
    // They have functions attached to them, so decoding them to tables wouldn't work
    Vec2(Vec2),
}

#[derive(Eq, PartialEq, Ord, PartialOrd)]
#[derive(Serialize, Deserialize)]
pub struct Vec2 {
    #[serde(serialize_with = "f64::serialize", deserialize_with = "deserialize_ordered_float")]
    pub x: OrderedFloat<f64>,
    #[serde(serialize_with = "f64::serialize", deserialize_with = "deserialize_ordered_float")]
    pub y: OrderedFloat<f64>,
}
