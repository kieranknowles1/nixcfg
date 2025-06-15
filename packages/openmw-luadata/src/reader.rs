use std::fs::File;
use std::io::{BufRead, BufReader, Read};
use std::string::FromUtf8Error;

use thiserror::Error;

use crate::constants::*;
use crate::value::{Array, Table, Value, Vec2, Vec3};

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
        Err(Error::data(&format!(
            "Invalid format version: 0x{:02X}, expected 0x{:02X}",
            version, FORMAT_VERSION
        )))?;
    }

    let value = read_value(&mut reader)?;

    // A storage file/sub record should contain exactly one value, with no trailing data
    // If there is, we have a corrupt file, or the decoder got misaligned
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

/// Decode a value from the reader
/// Consumes as much data as needed to decode the value
/// Recurses into tables
fn read_value<T: Read>(reader: &mut PrimitiveReader<T>) -> Result<Value> {
    let tag = reader.u8()?;

    match tag {
        T_NUMBER => {
            let number = reader.f64()?;
            Ok(Value::Number(number))
        }
        T_LONG_STRING => {
            let length = reader.u32()? as usize;
            let string = reader.string(length)?;
            Ok(Value::String(string))
        }
        T_BOOLEAN => {
            let value = reader.u8()?;
            Ok(Value::Boolean(value != 0))
        }
        T_TABLE_START => {
            let is_array = reader.peek_u8()? == T_NUMBER;
            match is_array {
                true => Ok(Value::Array(read_array(reader)?)),
                false => Ok(Value::Table(read_table(reader)?)),
            }
        }
        T_VEC2 => {
            let x = reader.f64()?;
            let y = reader.f64()?;
            Ok(Value::Vec2(Vec2 { x, y }))
        }
        T_VEC3 => {
            let x = reader.f64()?;
            let y = reader.f64()?;
            let z = reader.f64()?;
            Ok(Value::Vec3(Vec3 { x, y, z }))
        }
        // Every bit after the flag is part of the length, so we can use a range and mask
        T_SHORTSTRING_START..=T_SHORTSTRING_END => {
            let length = (tag & MASK_SHORT_STRING) as usize;
            let string = reader.string(length)?;
            Ok(Value::String(string))
        }
        _ => Err(Error::data(&format!("Unknown tag: 0x{:02X}", tag))),
    }
}

fn read_array<T: Read>(reader: &mut PrimitiveReader<T>) -> Result<Array> {
    let mut arr = Vec::new();

    let mut index = 1; // Lua arrays start at 1
    loop {
        let tag = reader.peek_u8()?;
        if tag == T_TABLE_END {
            reader.u8()?;
            return Ok(arr);
        }

        let key = read_value(reader)?;
        if key != Value::Number(index.into()) {
            return Err(Error::data(&format!("Expected {}, got {:?}", index, key)));
        }
        let value = read_value(reader)?;
        arr.push(value);

        index += 1;
    }
}

/// Decode a table from the reader
/// Assumes that the buffer points to the first byte after TABLE_START
fn read_table<T: Read>(reader: &mut PrimitiveReader<T>) -> Result<Table> {
    let mut table = Table::new();

    // Read until we see TABLE_END in place of the key's type
    loop {
        let tag = reader.peek_u8()?;
        if tag == T_TABLE_END {
            reader.u8()?; // Consume the TABLE_END
            return Ok(table);
        }

        let key = match read_value(reader)? {
            Value::String(s) => s,
            _ => Err(Error::data("Table key must be a string"))?,
        };
        let value = read_value(reader)?;
        table.insert(key, value);
    }
}
