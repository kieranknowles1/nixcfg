use std::io::Write;

use crate::constants::*;
use crate::value::{Array, Table, Value};

type Result<T> = std::io::Result<T>;

struct PrimitiveWriter<T: Write> {
    writer: T,
}

impl<T: Write> PrimitiveWriter<T> {
    fn new(writer: T) -> Self {
        Self { writer }
    }

    fn u8(&mut self, value: u8) -> Result<()> {
        self.writer.write_all(&[value])
    }

    fn u32(&mut self, value: u32) -> Result<()> {
        self.writer.write_all(&value.to_le_bytes())
    }

    fn f64(&mut self, value: f64) -> Result<()> {
        self.writer.write_all(&value.to_le_bytes())
    }
}

pub fn encode(value: Value, writer: &mut impl Write) -> Result<()> {
    let mut writer = PrimitiveWriter::new(writer);

    // Write the format version, then pass off to the recursive function
    writer.u8(FORMAT_VERSION)?;
    write_value(value, &mut writer)?;

    Ok(())
}

fn write_value(value: Value, write: &mut PrimitiveWriter<impl Write>) -> Result<()> {
    match value {
        Value::Number(n) => {
            write.u8(T_NUMBER)?;
            write.f64(n)?;
        }
        Value::Boolean(b) => {
            write.u8(T_BOOLEAN)?;
            write.u8(if b { 1 } else { 0 })?;
        }
        Value::String(s) => {
            write_string(&s, write)?;
        }
        Value::Table(t) => {
            write_table(t, write)?;
        }
        Value::Array(a) => {
            write_array(a, write)?;
        }
        Value::Vec2(x, y) => {
            write.u8(T_VEC2)?;
            write.f64(x)?;
            write.f64(y)?;
        }
    }

    Ok(())
}

fn write_array(array: Array, write: &mut PrimitiveWriter<impl Write>) -> Result<()> {
    write.u8(T_TABLE_START)?;
    let mut i = 1; // Lua arrays start at 1
    for value in array {
        write_value(Value::Number(i.into()), write)?;
        write_value(value, write)?;
        i += 1;
    }
    write.u8(T_TABLE_END)?;
    Ok(())
}

fn write_table(table: Table, write: &mut PrimitiveWriter<impl Write>) -> Result<()> {
    write.u8(T_TABLE_START)?;
    for (key, value) in table {
        write_string(&key, write)?;
        write_value(value, write)?;
    }

    write.u8(T_TABLE_END)?;

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

    if length <= MASK_SHORT_STRING.into() {
        // Short string format. Length is stored in the lower 5 bits
        write.u8(FLAG_SHORT_STRING | length as u8)?;
    } else {
        // Long string format. Length is stored in a 32-bit integer
        write.u8(T_LONG_STRING)?;
        write.u32(length)?;
    }

    write.writer.write_all(string.as_bytes())?;
    Ok(())
}
