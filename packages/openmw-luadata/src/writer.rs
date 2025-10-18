use std::io::Write;

use crate::byteconv::ByteConv;
use crate::tag::{FORMAT_VERSION, MAX_SHORTSTRING_LENGTH, Tag};
use crate::value::{Table, Value};

type Result<T> = std::io::Result<T>;

struct PrimitiveWriter<T: Write> {
    writer: T,
}

impl<T: Write> PrimitiveWriter<T> {
    fn new(writer: T) -> Self {
        Self { writer }
    }

    fn write<V: ByteConv<SIZE>, const SIZE: usize>(&mut self, value: V) -> Result<()> {
        self.writer.write_all(&value.to_bytes())
    }
}

pub fn encode(value: Value, writer: &mut impl Write) -> Result<()> {
    let mut writer = PrimitiveWriter::new(writer);

    // Write the format version, then pass off to the recursive function
    writer.write(FORMAT_VERSION)?;
    write_value(value, &mut writer)?;

    Ok(())
}

fn write_value(value: Value, write: &mut PrimitiveWriter<impl Write>) -> Result<()> {
    match value {
        Value::Number(n) => {
            write.write(Tag::Number)?;
            write.write(n)?;
        }
        Value::Boolean(b) => {
            write.write(Tag::Boolean)?;
            write.write(u8::from(b))?;
        }
        Value::String(s) => {
            write_string(&s, write)?;
        }
        Value::Table(t) => {
            write_table(t, write)?;
        }
        Value::Vec2(v) => {
            write.write(Tag::Vec2)?;
            write.write(v.x)?;
            write.write(v.y)?;
        }
        Value::Vec3(v) => {
            write.write(Tag::Vec3)?;
            write.write(v.x)?;
            write.write(v.y)?;
            write.write(v.z)?;
        }
        Value::Color(c) => {
            write.write(Tag::Color)?;
            write.write(c.r)?;
            write.write(c.g)?;
            write.write(c.b)?;
            write.write(c.a)?;
        }
    }

    Ok(())
}

fn write_table(table: Table, write: &mut PrimitiveWriter<impl Write>) -> Result<()> {
    write.write(Tag::TableStart)?;
    for (key, value) in table {
        write_value(key, write)?;
        write_value(value, write)?;
    }

    write.write(Tag::TableEnd)?;

    Ok(())
}

/// Write a string to the writer
/// Uses the short string format if possible, long string format otherwise
fn write_string(string: &str, write: &mut PrimitiveWriter<impl Write>) -> Result<()> {
    // OpenMW uses 32-bit lengths. Should never be a problem in practice
    let length = if string.len() >= u32::MAX as usize {
        return Err(std::io::Error::new(
            std::io::ErrorKind::InvalidInput,
            "String too long",
        ));
    } else {
        string.len() as u32
    };

    if length <= MAX_SHORTSTRING_LENGTH.into() {
        // Short string format. Length is stored in the lower bits
        // SAFETY: MAX_SHORTSTRING_LENGTH is a u8
        write.write(Tag::ShortString(length as u8))?;
    } else {
        // Long string format. Length is stored in a 32-bit integer
        write.write(Tag::LongString)?;
        write.write(length)?;
    }

    write.writer.write_all(string.as_bytes())?;
    Ok(())
}
