use std::path::Path;

use sha2::{Digest, Sha256};

pub type Hash = [u8; 32];

pub type Result<T> = std::io::Result<T>;

pub enum ExistingMatch {
    // The home file is identical to the new file.
    EqualNew,
    // The home file is identical to the old file.
    EqualOld,
    // The home file differs from both the old and new files.
    Conflict,
}

impl ExistingMatch {
    // Compare the current home file with the new and old files.
    pub fn from_hashes(old_hash: Option<Hash>, new_hash: Hash, home_hash: Hash) -> Self {
        if new_hash == home_hash {
            ExistingMatch::EqualNew
        } else if Some(home_hash) == old_hash {
            ExistingMatch::EqualOld
        } else {
            // The files differ, or we have no previous file to compare to.
            // A non-existent file is never identical to an existing file.
            ExistingMatch::Conflict
        }
    }
}

pub fn hash_file(path: &Path) -> Result<Hash> {
    let data = std::fs::read(path)?;
    let digest = Sha256::digest(&data);
    Ok(digest.into())
}
