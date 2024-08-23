use std::collections::BTreeMap;
use std::fs::File;
use std::io::{BufRead, BufReader, Read};
use std::string::FromUtf8Error;

use ordered_float::OrderedFloat;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum Error {
    #[error(transparent)]
    Io(#[from] std::io::Error),

    #[error(transparent)]
    Utf8(#[from] FromUtf8Error),

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
    let file = File::open(&file)?;
    let mut reader = PrimitiveReader::new(file);

    if reader.at_end()? {
        Err(Error::data("File is empty"))?;
    }

    let version = reader.u8()?;
    if version != FORMAT_VERSION {
        Err(Error::data(
            &format!("Invalid format version: 0x{:02X}, expected 0x{:02X}", version, FORMAT_VERSION))
        )?;
    }

    let value = Value::decode(&mut reader)?;

    if !reader.at_end()? {
        Err(Error::data("Trailing data"))?;
    }

    Ok(value)
}

struct PrimitiveReader<T: Read> {
    reader: BufReader<T>,
}

/// Helper to read and decode Lua primitives
/// Expects all data to be little-endian
impl<T: Read> PrimitiveReader<T> {
    fn new(reader: T) -> Self {
        Self {
            reader: BufReader::new(reader),
        }
    }

    /// Check if we're at the end of the file
    /// Uses a mutable reference as we may need to fill the buffer
    /// Does not consume the buffer
    fn at_end(&mut self) -> Result<bool> {
        Ok(self.reader.fill_buf()?.is_empty())
    }

    /// Read a single byte
    /// Consumes 1 byte
    fn u8(&mut self) -> Result<u8> {
        let mut buf = [0u8; 1];
        self.reader.read_exact(&mut buf)?;

        Ok(buf[0])
    }

    /// Read a single byte without consuming the buffer
    fn peek_u8(&mut self) -> Result<u8> {
        let buf = self.reader.fill_buf()?;
        if buf.is_empty() {
            Err(Error::data("Unexpected EOF"))?;
        }

        Ok(buf[0])
    }

    /// Read a 32-bit unsigned integer
    /// Consumes 4 bytes
    fn u32(&mut self) -> Result<u32> {
        let mut buf = [0u8; 4];
        self.reader.read_exact(&mut buf)?;

        Ok(u32::from_le_bytes(buf))
    }

    /// Read a double-precision float
    /// Consumes 8 bytes
    fn f64(&mut self) -> Result<f64> {
        let mut buf = [0u8; 8];
        self.reader.read_exact(&mut buf)?;

        Ok(f64::from_le_bytes(buf))
    }

    /// Read a fixed-size string
    /// Consumes size bytes
    fn string(&mut self, size: usize) -> Result<String> {
        let mut buf = vec![0u8; size];
        self.reader.read_exact(&mut buf)?;

        Ok(String::from_utf8(buf)?)
    }
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
    // OrderedFloat crate which wraps a f64 to implement the Ord trait
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
    /// Decode a value from the reader
    /// Consumes as much data as needed to decode the value
    /// Recurses into tables
    fn decode<T: Read>(reader: &mut PrimitiveReader<T>) -> Result<Self> {
        let tag = reader.u8()?;

        match tag {
            T_NUMBER => {
                let number = reader.f64()?;
                Ok(Self::Number(OrderedFloat(number)))
            },
            T_LONG_STRING => {
                let length = reader.u32()? as usize;
                let string = reader.string(length)?;
                Ok(Self::String(string))
            },
            T_BOOLEAN => {
                let value = reader.u8()?;
                Ok(Self::Boolean(value != 0))
            },
            T_TABLE_START => {
                let table = Self::decode_table(reader)?;
                Ok(Self::Table(table))
            },
            T_VEC2 => {
                let x = reader.f64()?;
                let y = reader.f64()?;
                Ok(Self::Vec2(OrderedFloat(x), OrderedFloat(y)))
            },
            // Every bit after the flag is part of the length, so we can use a range and mask
            0x20..=0x3F => {
                let length = (tag & MASK_SHORT_STRING) as usize;
                let string = reader.string(length)?;
                Ok(Self::String(string))
            },
            _ => {
                Err(Error::data(&format!("Unknown tag: 0x{:02X}", tag)))
            }
        }
    }

    /// Decode a table from the reader
    /// Assumes that the buffer points to the first byte after TABLE_START
    fn decode_table<T: Read>(reader: &mut PrimitiveReader<T>) -> Result<Table> {
        let mut table = Table::new();

        // Read until we see TABLE_END in place of the key's type
        loop {
            let tag = reader.peek_u8()?;
            if tag == T_TABLE_END {
                reader.u8()?; // Consume the TABLE_END
                return Ok(table);
            }

            // Table keys can be any type
            let key = Self::decode(reader)?;
            let value = Self::decode(reader)?;
            table.insert(key, value);
        }
    }
}
