use std::fs::File;
use std::io::{BufRead, BufReader, Read, Seek};
use std::string::FromUtf8Error;

use thiserror::Error;

use crate::byteconv::ByteConv;
use crate::tag::{FORMAT_VERSION, Tag};
use crate::value::{Color, Table, Value, Vec2, Vec3};

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

#[allow(clippy::doc_markdown)]
/// Decode a lua storage file in OpenMW's format
/// NOTE: Assumes that values are encoded in little-endian
pub fn decode(file: &str) -> Result<Value> {
    let file = File::open(file)?;
    let mut reader = PrimitiveReader::new(file);

    if reader.at_end()? {
        Err(Error::data("File is empty"))?;
    }

    let version: u8 = reader.read()?;
    if version != FORMAT_VERSION {
        Err(Error::data(&format!(
            "Invalid format version: 0x{version:02X}, expected 0x{FORMAT_VERSION:02X}"
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

struct PrimitiveReader<T: Read + Seek> {
    reader: BufReader<T>,
}

/// Helper to read and decode Lua primitives
/// Expects all data to be little-endian
impl<T: Read + Seek> PrimitiveReader<T> {
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

    /// Read a primitive and consume it
    fn read<V: ByteConv<SIZE>, const SIZE: usize>(&mut self) -> Result<V> {
        let mut buf = [0u8; SIZE];
        self.reader.read_exact(&mut buf)?;

        Ok(V::from_bytes(&buf))
    }

    /// Read a primitive without consuming it
    fn peek<V: ByteConv<SIZE>, const SIZE: usize>(&mut self) -> Result<V> {
        let val = self.read()?;
        self.reader.seek_relative(-(SIZE as i64))?;
        Ok(val)
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
fn read_value<T: Read + Seek>(reader: &mut PrimitiveReader<T>) -> Result<Value> {
    let tag = reader.read()?;

    match tag {
        Tag::Number => {
            let number = reader.read()?;
            Ok(Value::Number(number))
        }
        Tag::LongString => {
            let length: u32 = reader.read()?;
            let string = reader.string(length as usize)?;
            Ok(Value::String(string))
        }
        Tag::Boolean => {
            let value: u8 = reader.read()?;
            Ok(Value::Boolean(value != 0))
        }
        Tag::TableStart => Ok(Value::Table(read_table(reader)?)),
        Tag::Vec2 => {
            let x = reader.read()?;
            let y = reader.read()?;
            Ok(Value::Vec2(Vec2 { x, y }))
        }
        Tag::Vec3 => {
            let x = reader.read()?;
            let y = reader.read()?;
            let z = reader.read()?;
            Ok(Value::Vec3(Vec3 { x, y, z }))
        }
        Tag::Color => {
            let r = reader.read()?;
            let g = reader.read()?;
            let b = reader.read()?;
            let a = reader.read()?;
            Ok(Value::Color(Color { r, g, b, a }))
        }
        Tag::ShortString(length) => {
            let string = reader.string(length as usize)?;
            Ok(Value::String(string))
        }
        Tag::TableEnd => Err(Error::data("Table end outside of table key")),
    }
}

/// Decode a table from the reader
/// Assumes that the buffer points to the first byte after `TABLE_START`
fn read_table<T: Read + Seek>(reader: &mut PrimitiveReader<T>) -> Result<Table> {
    let mut table = Table::new();

    // Read until we see TABLE_END in place of the key's type
    loop {
        let tag: Tag = reader.peek()?;
        if tag == Tag::TableEnd {
            reader.read::<Tag, 1>()?; // Consume the TABLE_END
            return Ok(table);
        }

        let key = read_value(reader)?;
        let value = read_value(reader)?;
        table.insert(key, value);
    }
}
