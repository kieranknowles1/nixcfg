use std::path::Path;

use crate::config::ConfigEntry;

pub type Result<T> = std::io::Result<T>;
pub type FileContents = Vec<u8>;

pub enum ExistingMatch {
    /// The home file is identical to the new file.
    EqualNew,
    /// The home file is identical to the old file.
    EqualOld,
    /// The home file differs from both the old and new files.
    Conflict,
    /// File is not present in home
    NotInHome,
}

pub struct Files {
    store: FileContents,
    old_store: Option<FileContents>,
    home: Option<FileContents>,
}

impl Files {
    pub fn read(
        entry: &ConfigEntry,
        old_entry: Option<&ConfigEntry>,
        destination: &Path,
    ) -> Result<Self> {
        let store = std::fs::read(&entry.source)?;
        let old_store = match old_entry {
            Some(o) => Some(std::fs::read(&o.source)?),
            None => None,
        };
        let home = match std::fs::exists(&destination)? {
            true => Some(std::fs::read(&destination)?),
            false => None,
        };

        Ok(Self {
            store,
            old_store,
            home,
        })
    }

    pub fn compare(&self) -> ExistingMatch {
        if self.home == None {
            ExistingMatch::NotInHome
        } else if self.home == self.old_store {
            ExistingMatch::EqualOld
        } else if self.home.as_ref() == Some(&self.store) {
            ExistingMatch::EqualNew
        } else {
            ExistingMatch::Conflict
        }
    }
}
