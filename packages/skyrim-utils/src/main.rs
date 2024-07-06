// cSpell: words skse shellexpand skyrim

use std::fs;
use std::io::Result;
use std::path::PathBuf;
use std::collections::HashSet;
use shellexpand;

/// A representation of all found .ess and .skse files in a directory
struct SaveFiles {
    ess_files: HashSet<PathBuf>,
    skse_files: HashSet<PathBuf>,
}

impl SaveFiles {
    fn collect(dir: &str) -> Result<Self> {
        let mut ess_files = HashSet::new();
        let mut skse_files = HashSet::new();

        for file in fs::read_dir(dir)? {
            let path = file?.path();

            let extension = match path.extension() {
                Some(ext) => ext.to_str(),
                None => None,
            };

            match extension {
                Some("ess") => ess_files.insert(path),
                Some("skse") => skse_files.insert(path),
                _ => continue, // It is valid to have files in the directory that are not .ess or .skse files
            };
        }

        Ok(Self {
            ess_files,
            skse_files,
        })
    }

    /// Get all .skse files that do not have a corresponding .ess file
    fn get_orphans(self) -> Vec<PathBuf> {
        self.skse_files.into_iter()
            .filter(|skse| !self.ess_files.contains(&skse.with_extension("ess")))
            .collect()
    }
}

fn main() -> Result<()> {
    // TODO: Don't hardcode this, this is currently a symlink to MO2's actual profile. Probably use Nix or something
    let save_dir = shellexpand::tilde("~/Documents/src/dotfiles/configs/games/skyrim/profile/saves");

    let save_files = SaveFiles::collect(&save_dir)?;

    let orphans = save_files.get_orphans();

    match orphans.is_empty() {
        true => println!("Nothing to do"),
        false => for skse in &orphans {
            println!("Deleting {:?}", skse.file_name().unwrap_or_default());
            fs::remove_file(skse)?;
        },

    }

    Ok(())
}
