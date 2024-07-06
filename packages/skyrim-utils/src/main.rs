// cSpell: words skse shellexpand skyrim

use std::fs::{self, DirEntry};
use std::io::Result;
use std::path::PathBuf;
use std::collections::HashSet;
use clap::builder::OsStr;
use shellexpand;
use clap::{Args, Parser};

#[derive(Parser)]
enum Arguments {
    /// Clean up orphaned .skse files
    Clean(CleanArgs),
    /// Open the latest save file
    Latest(LatestArgs),
}

#[derive(Args)]
struct CleanArgs {}

impl CleanArgs {
    fn run(&self, save_dir: &str) -> Result<()> {
        let save_files = SaveFiles::collect(&save_dir)?;

        let orphans = save_files.get_orphans();

        match orphans.is_empty() {
            true => println!("Nothing to do"),
            false => for skse in &orphans {
                println!("Deleting {:?}", skse.file_name().unwrap_or_default());
                fs::remove_file(skse)?;
            },
        };

        Ok(())
    }
}

#[derive(Args)]
struct LatestArgs {}

impl LatestArgs {
    fn run(&self, save_dir: &str) -> Result<()> {
        let latest = SaveFiles::get_latest(&save_dir)?;

        open::that(latest)?;

        Ok(())
    }
}

/// A representation of all found .ess and .skse files in a directory
struct SaveFiles {
    ess_files: HashSet<PathBuf>,
    skse_files: HashSet<PathBuf>,
}

/// Get the extension of a file as a plain string rather than an OsStr
/// Returns None if the file has no extension or if the extension is not valid UTF-8
/// (which should never happen, but Linux allows newlines so who knows what else is possible)
fn extension_plain_str(path: &PathBuf) -> Option<&str> {
    match path.extension() {
        Some(ext) => ext.to_str(),
        None => None,
    }
}

impl SaveFiles {
    fn collect(dir: &str) -> Result<Self> {
        let mut ess_files = HashSet::new();
        let mut skse_files = HashSet::new();

        for file in fs::read_dir(dir)? {
            let path = file?.path();

            match extension_plain_str(&path) {
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

    fn get_latest(dir: &str) -> Result<PathBuf> {
        fn get_modified_time(file: &DirEntry) -> Option<std::time::SystemTime> {
            match file.metadata() {
                Ok(metadata) => metadata.modified().ok(),
                Err(_) => None,
            }
        }

        let newest = fs::read_dir(dir)?
            .flatten() // Remove any errors
            .filter(|file| extension_plain_str(&file.path()) == Some("ess"))
            .max_by_key(get_modified_time);

        match newest {
            Some(file) => Ok(file.path()),
            None => Err(std::io::Error::new(std::io::ErrorKind::NotFound, "No files found")),
        }
    }

    /// Get all .skse files that do not have a corresponding .ess file
    fn get_orphans(self) -> Vec<PathBuf> {
        self.skse_files.into_iter()
            .filter(|skse| !self.ess_files.contains(&skse.with_extension("ess")))
            .collect()
    }
}

fn main() -> Result<()> {
    let args = Arguments::parse();

    // TODO: Don't hardcode this, this is currently a symlink to MO2's actual profile. Probably use Nix or something
    let save_dir = shellexpand::tilde("~/Documents/src/dotfiles/configs/games/skyrim/profile/saves");

    match args {
        Arguments::Clean(clean_args) => clean_args.run(&save_dir),
        Arguments::Latest(latest_args) => latest_args.run(&save_dir),
    }?;

    Ok(())
}
