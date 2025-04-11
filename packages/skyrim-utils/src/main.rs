// cSpell: words skse shellexpand skyrim

use clap::{Args, Parser};
use regex::Regex;
use shellexpand;
use std::collections::HashSet;
use std::fs::{self, DirEntry};
use std::io::Result;
use std::path::PathBuf;

#[derive(Parser)]
enum Arguments {
    /// Clean up orphaned .skse files
    Clean(CleanArgs),
    /// Open the latest save file
    Latest(LatestArgs),
    /// Open the latest crash log
    Crash(CrashArgs),
}

#[derive(Args)]
struct CleanArgs {}

impl CleanArgs {
    fn run(&self, save_dir: &[PathBuf]) -> Result<()> {
        let save_files = SaveFiles::collect(&save_dir)?;

        let orphans = save_files.get_orphans();

        match orphans.is_empty() {
            true => println!("Nothing to do"),
            false => {
                for skse in &orphans {
                    fs::remove_file(skse)?;
                }
            }
        };

        println!("Deleted {} orphaned .skse files", orphans.len());

        Ok(())
    }
}

#[derive(Args)]
struct LatestArgs {}

impl LatestArgs {
    fn run(&self, save_dir: &[PathBuf]) -> Result<()> {
        let latest = SaveFiles::get_latest(save_dir)?;

        match latest {
            Some(path) => open::that(path)?,
            None => println!("No save files found"),
        };

        Ok(())
    }
}

#[derive(Args)]
struct CrashArgs {}

impl CrashArgs {
    fn run(&self, log_dir: &[PathBuf]) -> Result<()> {
        let pattern = Regex::new(r"crash-.*\.log").unwrap(); // We know this pattern is valid

        let latest = latest_file_matching_predicate(log_dir, |file| {
            let name = file.file_name();
            pattern.is_match(&name.to_string_lossy())
        })?;

        match latest {
            Some(file) => open::that(file.path())?,
            None => println!("No crash logs found"),
        };

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

fn latest_file_matching_predicate(
    dirs: &[PathBuf],
    predicate: impl Fn(&DirEntry) -> bool,
) -> Result<Option<DirEntry>> {
    fn get_modified_time(file: &DirEntry) -> Option<std::time::SystemTime> {
        match file.metadata() {
            Ok(metadata) => metadata.modified().ok(),
            Err(_) => None,
        }
    }

    let newest = dirs
        .iter()
        .flat_map(fs::read_dir) // Read directory entries, ignoring errors
        .flatten() // Flatten the directory into a list of files
        .flat_map(Result::ok) // Ignore any errors reading file meta
        .filter(predicate)
        .max_by_key(get_modified_time);

    Ok(newest)
}

impl SaveFiles {
    fn collect(dirs: &[PathBuf]) -> Result<Self> {
        let mut ess_files = HashSet::new();
        let mut skse_files = HashSet::new();

        for dir in dirs {
            let read = fs::read_dir(dir);
            match read {
                Ok(contents) => {
                    for file in contents {
                        let path = file?.path();

                        match extension_plain_str(&path) {
                            Some("ess") => ess_files.insert(path),
                            Some("skse") => skse_files.insert(path),
                            _ => continue, // It is valid to have files in the directory that are not .ess or .skse files
                        };
                    }
                }
                Err(_) => eprintln!("Could not read directory: {}, skipping", dir.display()),
            }
        }

        Ok(Self {
            ess_files,
            skse_files,
        })
    }

    fn get_latest(dir: &[PathBuf]) -> Result<Option<PathBuf>> {
        let latest = latest_file_matching_predicate(dir, |file| {
            extension_plain_str(&file.path()) == Some("ess")
        });

        match latest {
            Ok(Some(file)) => Ok(Some(file.path())),
            Ok(None) => Ok(None),
            Err(e) => Err(e),
        }
    }

    /// Get all .skse files that do not have a corresponding .ess file
    fn get_orphans(self) -> Vec<PathBuf> {
        self.skse_files
            .into_iter()
            .filter(|skse| !self.ess_files.contains(&skse.with_extension("ess")))
            .collect()
    }
}

fn profile_saves(profile: &str) -> PathBuf {
    let base = shellexpand::tilde("~/Documents/src/dotfiles/configs/games/skyrim/").to_string();

    PathBuf::from(base).join(profile).join("saves")
}

fn main() -> Result<()> {
    let args = Arguments::parse();

    // God that's a mouthful, I blame Windows for not using the Unix file structure
    let data_dir = shellexpand::tilde("~/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/Documents/My Games/Skyrim Special Edition").to_string();
    let data_dir = PathBuf::from(data_dir);

    let save_dirs = vec![profile_saves("profile"), data_dir.join("Saves")];
    let log_dir = vec![data_dir.join("SKSE")];

    match args {
        Arguments::Clean(clean_args) => clean_args.run(&save_dirs),
        Arguments::Latest(latest_args) => latest_args.run(&save_dirs),
        Arguments::Crash(crash_args) => crash_args.run(&log_dir),
    }?;

    Ok(())
}
