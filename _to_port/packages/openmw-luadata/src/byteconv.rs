// Fixed-size type that can be converted to and from a byte array.
// Integers are represented in little-endian byte order. (x86 uses this natively)
//
// We need our own trait as there is no standard trait for this, even though there
// is a function :(, so we need extra boilerplate to cover it.
//
// Rust doesn't have much I miss from C++, but templates having absolute power is
// one of them. Lack of boilerplate wasn't quite enough to compensate for compiler
// errors in MSVC however.
pub trait ByteConv<const SIZE: usize> {
    fn to_bytes(&self) -> [u8; SIZE];
    fn from_bytes(bytes: &[u8; SIZE]) -> Self;
}

macro_rules! impl_byteconv {
    ($type:ty, $size:expr) => {
        impl ByteConv<$size> for $type {
            fn to_bytes(&self) -> [u8; $size] {
                self.to_le_bytes()
            }

            fn from_bytes(bytes: &[u8; $size]) -> Self {
                <$type>::from_le_bytes(*bytes)
            }
        }
    };
}

impl_byteconv!(u8, 1);
impl_byteconv!(u32, 4);
impl_byteconv!(f32, 4);
impl_byteconv!(f64, 8);
