use std::{borrow::Borrow, io, path::{Path, PathBuf}};
use config::{AbsoluteProgramConfig, Config};
use clap::Parser;
use walkdir::WalkDir;

mod config;

#[derive(Parser)]
struct Args {
    /// The program to configure
    program: String,

    /// Whether to perform a dry run (don't actually change anything)
    #[clap(short, long)]
    dry_run: bool,
}

/// Error for when a program is not found in the config
#[derive(Debug, Clone)]
struct ProgramNotFoundError {
    program: String,
}
impl std::fmt::Display for ProgramNotFoundError {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "Program not found: {}", self.program)
    }
}
impl std::error::Error for ProgramNotFoundError {}

fn get_config() -> Result<Config, Box<dyn std::error::Error>> {
    let config_path = shellexpand::tilde("~/.config/edit-config.json");
    let config_path_borrow: &str = config_path.borrow();

    let config_str = std::fs::read_to_string(config_path_borrow)?;

    Ok(Config::from_str(&config_str)?)
}

struct BackupPath {
    repo_path: PathBuf,
    system_path: PathBuf,
}

/// Collect a list of paths to back up so that they will be editable
fn collect_backup_paths(program: &AbsoluteProgramConfig) -> Vec<BackupPath> {
    WalkDir::new(&program.system_path)
        .into_iter()
        .flatten() // TODO: This discards errors, which is bad
        .filter(|entry| !program.is_ignored(entry.path()))
        .filter(|entry| !entry.file_type().is_dir())
        .map(|entry| {
            let system_path = entry.path().to_path_buf();
            // An error means the path is not in system_path, which should never happen
            let repo_path = program.to_repo_path(&system_path).unwrap();

            BackupPath { repo_path, system_path }
        })
        .collect()
}

struct SwappedLink {
    link_backup: PathBuf,
    real_file: PathBuf,
    repo_file: PathBuf,
}

fn swap_link_from_repo(path: BackupPath, dry_run: bool) -> io::Result<SwappedLink> {
    let backup_path = path.system_path.with_extension("edit-config-backup");

    match dry_run {
        true => {
            println!("Would rename {} to {}", path.system_path.display(), backup_path.display());
        },
        false => {
            println!("Renaming {} to {}", path.system_path.display(), backup_path.display());
            std::fs::rename(&path.system_path, &backup_path)?;
            std::fs::copy(&path.repo_path, &path.system_path)?;
        }
    }

    Ok(SwappedLink {
        link_backup: backup_path,
        real_file: path.system_path,
        repo_file: path.repo_path,
    })
}

/// Backup links, then swap them with the current repository state
fn swap_links_with_repo(paths: Vec<BackupPath>, dry_run: bool) -> io::Result<Vec<SwappedLink>> {
    let mut swapped = Vec::new();

    for path in paths {
        swapped.push(swap_link_from_repo(path, dry_run)?);
    }

    Ok(swapped)
}

fn open_editor(command: &str, system_path: &Path) -> io::Result<()> {
    std::process::Command::new(command)
        .arg(system_path)
        .status()?;

    // GUI editors may detach from the terminal, so we need to wait for user input
    // before continuing
    println!("Press enter to continue...");
    let mut input = String::new();
    io::stdin().read_line(&mut input)?;

    Ok(())
}

fn restore_single_link(link: &SwappedLink, dry_run: bool) -> io::Result<()> {
    match dry_run {
        true => {
            println!("Would restore {} to {}", link.real_file.display(), link.link_backup.display());
        },
        false => {
            // Copy any changes made to the system file back to the repository
            std::fs::copy(&link.real_file, &link.repo_file)?;

            // Restore the original link
            std::fs::rename(&link.link_backup, &link.real_file)?;
        }
    }

    Ok(())
}

fn restore_links(links: Vec<SwappedLink>, dry_run: bool) -> io::Result<()> {
    links.iter()
        .map(|link| restore_single_link(link, dry_run))
        .collect()
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let config = get_config()?;
    let args = Args::parse();

    let program = match config.programs.get(&args.program) {
        Some(program) => program.to_absolute(&config.repository),
        None => Err(ProgramNotFoundError { program: args.program })?,
    };

    let paths = collect_backup_paths(&program);

    let swapped_links = swap_links_with_repo(paths, args.dry_run)?;
    open_editor(&config.editor, &program.system_path)?;
    restore_links(swapped_links, args.dry_run)?;

    Ok(())
}
