use std::{path::Path, process::Command};

use crate::config::ConfigEntry;

pub type Result<T> = std::io::Result<T>;
pub type FileContents = Vec<u8>;

#[derive(Clone, Copy)]
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
        let store = Self::read_transformed(&entry.source, transform)?;
        let old_store = match old_entry {
            Some(o) => Some(Self::read_transformed(&o.source, transform)?),
            None => None,
        };
        let home = match std::fs::exists(destination)? {
            true => Some(Self::read_transformed(destination, transform)?),
            false => None,
        };

        Ok(Self {
            store,
            old_store,
            home,
        })
    }

    pub fn read_transformed(file: &Path, transform: Option<&Path>) -> Result<FileContents> {
        match transform {
            Some(trans) => {
                let out = Command::new(trans).arg(file).output()?;
                match out.status.success() {
                    true => Ok(out.stdout),
                    false => Err(std::io::Error::other("Transform failed")),
                }
            }
            None => std::fs::read(file),
        }
    }

    pub fn compare(&self) -> ExistingMatch {
        if self.home.is_none() {
            // File doesn't exist in home - will be deployed no matter what
            ExistingMatch::NotInHome
        } else if self.home.as_ref() == Some(&self.store) {
            // File exists and matches current generation - no need to deploy
            ExistingMatch::EqualNew
        } else if self.home == self.old_store {
            // File exists and matches previous, but not current, generation - deploy the updated version
            ExistingMatch::EqualOld
        } else {
            // File doesn't match either previous or current - handle base on `on_conflict`
            ExistingMatch::Conflict
        }
    }
}
