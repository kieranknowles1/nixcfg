pub const FORMAT_VERSION: u8 = 0x00;

pub const T_NUMBER: u8 = 0x00;
pub const T_LONG_STRING: u8 = 0x01;
pub const T_BOOLEAN: u8 = 0x02;
pub const T_TABLE_START: u8 = 0x03;
pub const T_TABLE_END: u8 = 0x04;
pub const T_VEC2: u8 = 0x10;
pub const T_VEC3: u8 = 0x11;

pub const FLAG_SHORT_STRING: u8 = 0x20;
pub const MASK_SHORT_STRING: u8 = 0x1F;

pub const T_SHORTSTRING_START: u8 = FLAG_SHORT_STRING;
pub const T_SHORTSTRING_END: u8 = FLAG_SHORT_STRING + MASK_SHORT_STRING;
