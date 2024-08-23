use std::collections::BTreeMap;
use std::fs::File;
use std::io::Read;
use std::str::Utf8Error;

use ordered_float::OrderedFloat;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum Error {
    #[error(transparent)]
    Io(#[from] std::io::Error),

    #[error(transparent)]
    Utf8(#[from] Utf8Error),

    #[error("Invalid data: {0}")]
    InvalidData(String),
}

impl Error {
    pub fn data(msg: &str) -> Self {
        Self::InvalidData(msg.to_string())
    }
}


pub type Result<T> = std::result::Result<T, Error>;

pub const FORMAT_VERSION: u8 = 0x00;

/// Decode a lua storage file in OpenMW's format
/// NOTE: Assumes that values are encoded in little-endian
pub fn decode(file: &str) -> Result<Value> {
    let mut file = File::open(&file)?;
    let mut data = Vec::new();
    file.read_to_end(&mut data)?;

    if data.len() < 1 {
        Err(Error::data("File is empty"))?;
    }

    let Rest (rest, version) = read_u8(&data)?;
    if version != FORMAT_VERSION {
        Err(Error::data(
            &format!("Invalid format version: 0x{:02X}, expected 0x{:02X}", version, FORMAT_VERSION))
        )?;
    }

    let Rest (unused, value) = Value::decode(rest)?;

    if !unused.is_empty() {
        Err(std::io::Error::new(
            std::io::ErrorKind::InvalidData,
            "Trailing data",
        ))?;
    }

    Ok(value)
}

/// A value, and the unparsed data that follows it
/// The lifetime parameter `'a` enforces that the borrowed slice is valid for at least as long as
/// the `Rest` struct
struct Rest<'a, T>(&'a [u8], T);

fn check_available(data: &[u8], size: usize) -> Result<()> {
    if data.len() < size {
        Err(Error::data(
            &format!("Tried to read {} bytes, but only {} bytes are available", size, data.len())
        ))?;
    }

    Ok(())
}

/// Read a fixed-size slice from the data, or return an error if it's not available
fn checked_read<const SIZE: usize>(data: &[u8]) -> Result<Rest<&[u8; SIZE]>> {
    check_available(data, SIZE)?;
    // This is safe because we just checked that the slice is long enough, and the size is fixed
    let bytes = data[..SIZE].try_into().unwrap();
    Ok(Rest(&data[SIZE..], bytes))
}

/// Read a slice of a given size from the data, or return an error if it's not available
/// Use checked_read instead if the size is known at compile time, as the compiler knows
/// more about the size and should produce faster/safer code
fn checked_runtime_read(data: &[u8], size: usize) -> Result<Rest<&[u8]>> {
    check_available(data, size)?;
    Ok(Rest(&data[size..], &data[..size]))
}

fn read_u8(data: &[u8]) -> Result<Rest<u8>> {
    let Rest (data, value): Rest<&[u8; 1]> = checked_read(data)?;

    Ok(Rest(data, value[0]))
}

fn read_u32(data: &[u8]) -> Result<Rest<u32>> {
    let Rest (data, value): Rest<&[u8; 4]> = checked_read(data)?;

    let int = u32::from_le_bytes(*value);

    Ok(Rest(data, int))
}

fn peek_u8(data: &[u8]) -> Result<u8> {
    if data.is_empty() {
        Err(Error::data(
            "Unexpected end of data"
        ))?;
    }

    Ok(data[0])
}

fn read_f64(data: &[u8]) -> Result<Rest<f64>> {
    let Rest (data, value): Rest<&[u8; 8]> = checked_read(data)?;

    let float = f64::from_le_bytes(*value);

    Ok(Rest(data, float))
}

// We use a btree instead of a hashmap to ensure that the keys are sorted
// This results in predictable ordering
// NOTE: If a table uses another table as a key, ordering will probably be weird anyway
// But if you do that, you're weird
type Table = BTreeMap<Value, Value>;

/// A value in the storage file
#[derive(Eq, PartialEq, Ord, PartialOrd)]
#[derive(Debug)]
pub enum Value {
    // Rust doesn't let us have ordered floats, as NaN causes ambiguity. We instead use the
    // OrderedFloat crate which wraps a f64 to implement the Ord traI'm
    Number(OrderedFloat<f64>),
    Boolean(bool),
    String(String),
    Table(Table),

    // OpenMW-specific types
    // These are not lua types, but instead userdata types that OpenMW uses
    // They have functions attached to them, so decoding them to tables wouldn't work
    Vec2(OrderedFloat<f64>, OrderedFloat<f64>),
}

const T_NUMBER: u8 = 0x00;
const T_LONG_STRING: u8 = 0x01;
const T_BOOLEAN: u8 = 0x02;
const T_TABLE_START: u8 = 0x03;
const T_TABLE_END: u8 = 0x04;
const T_VEC2: u8 = 0x10;

const MASK_SHORT_STRING: u8 = 0x1F;

impl Value {
    fn decode(data: &[u8]) -> Result<Rest<Value>> {
        let Rest (data, tag) = read_u8(data)?;

        match tag {
            T_NUMBER => {
                let Rest (data, number) = read_f64(data)?;
                Ok(Rest(data, Self::Number(OrderedFloat(number))))
            },
            T_LONG_STRING => {
                let Rest (data, length) = read_u32(data)?;
                let length = length as usize;
                let Rest (data, string) = checked_runtime_read(data, length)?;
                let string = std::str::from_utf8(string)?;

                Ok(Rest(data, Self::String(string.to_string())))
            },
            T_BOOLEAN => {
                let Rest (data, value) = read_u8(data)?;
                Ok(Rest(data, Self::Boolean(value != 0)))
            },
            T_TABLE_START => {
                let Rest(data, table) = Self::decode_table(data)?;
                Ok(Rest(data, Self::Table(table)))
            },
            T_TABLE_END => {
                // The only legal place for TABLE_END is in place of a table key
                // This function should never be asked to decode it, as it's handled by decode_table
                Err(Error::data(
                    "Unexpected table end"
                ))
            }
            T_VEC2 => {
                let Rest (data, x) = read_f64(data)?;
                let Rest (data, y) = read_f64(data)?;
                Ok(Rest(data, Self::Vec2(OrderedFloat(x), OrderedFloat(y))))
            },
            0x20..=0x3f => {
                let length = (tag & MASK_SHORT_STRING) as usize;
                let string = std::str::from_utf8(&data[..length])?;
                Ok(Rest(&data[length..], Self::String(string.to_string())))
            },
            _ => {
                Err(Error::data(&format!("Unknown tag: 0x{:02X}", tag)))
            }
        }
    }

    fn decode_table(data: &[u8]) -> Result<Rest<Table>> {
        let mut table = Table::new();
        let mut data = data;

        // Decode key-value pairs until we find a terminator
        loop {
            let tag = peek_u8(data)?;
            if tag == T_TABLE_END {
                return Ok(Rest(&data[1..], table));
            }

            // Make sure we advance the data pointer after each read
            let key_pair = Self::decode(data)?;
            data = key_pair.0;
            let key = key_pair.1;

            let value_pair = Self::decode(data)?;
            data = value_pair.0;
            let value = value_pair.1;
            table.insert(key, value);
        }
    }
}
