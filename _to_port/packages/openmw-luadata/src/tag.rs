use crate::byteconv::ByteConv;

pub const FORMAT_VERSION: u8 = 0x00;

const FLAG_SHORT_STRING: u8 = 0x20;
const MASK_SHORT_STRING: u8 = 0x1F;

const SHORTSTRING_START: u8 = FLAG_SHORT_STRING;
const SHORTSTRING_END: u8 = FLAG_SHORT_STRING + MASK_SHORT_STRING;

// Max length is the mask making it 15 bytes
// Don't expose the mask directly as it is an implementation detail
pub const MAX_SHORTSTRING_LENGTH: u8 = MASK_SHORT_STRING;

#[derive(Eq, PartialEq)]
pub enum Tag {
    Number,
    LongString,
    Boolean,
    TableStart,
    TableEnd,
    Vec2,
    Vec3,
    Color,
    ShortString(u8),
}

macro_rules! impl_tag {
    ($($variant:ident => $value:expr,)*) => {
        impl ByteConv<1> for Tag {
            fn from_bytes(bytes: &[u8; 1]) -> Self {
                match bytes[0] {
                    $($value => Tag::$variant,)*
                    SHORTSTRING_START..=SHORTSTRING_END => Tag::ShortString(bytes[0] & MASK_SHORT_STRING),
                    _ => panic!("Invalid tag"),
                }
            }

            fn to_bytes(&self) -> [u8; 1] {
                let val = match self {
                    $(Tag::$variant => $value,)*
                    Tag::ShortString(len) => FLAG_SHORT_STRING | len,
                };
                [val]
            }
        }
    };
}

impl_tag! {
    Number => 0x00,
    LongString => 0x01,
    Boolean => 0x02,
    TableStart => 0x03,
    TableEnd => 0x04,
    Vec2 => 0x10,
    Vec3 => 0x11,
    Color => 0x15,
}
