use std::{path::Path, process::Command};

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
        let transform = entry.transformer.as_deref();
        let store = Self::read_file(&entry.source, transform)?;
        let old_store = match old_entry {
            Some(o) => Some(Self::read_file(&o.source, transform)?),
            None => None,
        };
        let home = match std::fs::exists(&destination)? {
            true => Some(Self::read_file(&destination, transform)?),
            false => None,
        };

        Ok(Self {
            store,
            old_store,
            home,
        })
    }

    fn read_file(file: &Path, transform: Option<&Path>) -> Result<FileContents> {
        match transform {
            Some(trans) => Ok(Command::new(trans).arg(file).output()?.stdout),
            None => std::fs::read(file),
        }
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
