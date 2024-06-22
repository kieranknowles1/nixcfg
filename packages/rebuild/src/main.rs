// cSpell: words gethostname nixos

use clap::Parser;
use gethostname::gethostname;
use core::str;
use std::process::{Command, ExitStatus};
use std::env;

/// Configuration derived from the environment.
struct Config {
    /// The path to the flake repository.
    repo_path: String,
}

impl Config {
    fn new() -> Result<Self, env::VarError> {
        Ok(Self {
            repo_path: env::var("FLAKE")?,
        })
    }
}

/// Command-line options.
#[derive(Parser)]
struct Opt {
    /// The message to use for the commit.
    commit_message: String,

    /// If true, update flake inputs before rebuilding.
    #[arg(short, long)]
    update: bool,
}


fn check_ok(status: ExitStatus, command: &str) -> Result<(), std::io::Error> {
    match status.success() {
        true => Ok(()),
        false => Err(std::io::Error::new(std::io::ErrorKind::Other, format!("Command '{}' failed with status {}", command, status))),
    }
}

fn update_flake_inputs() -> std::io::Result<()> {
    let status = Command::new("nix")
        .arg("flake")
        .arg("update")
        .status()?;

    check_ok(status, "nix flake update")
}

/// Build the system with a fancy progress bar. Returns a diff between the current system and the build.
fn fancy_build(repo_path: &String) -> std::io::Result<String> {
    let build_status = Command::new("nh")
        .arg("os")
        .arg("build")
        .status()?;

    // We put build and diff in the same function as the diff only works after a build but
    // before a switch. This guarantees that we don't call it at the wrong time.
    check_ok(build_status, "nh os build")?;

    // nixos-rebuild doesn't have anything to do since we've already built the system
    // it will link the new generation to ./result for us to diff
    let dump_link_output = Command::new("nixos-rebuild")
        .arg("build")
        .arg("--flake").arg(repo_path)
        .output()?; // We use output to suppress stdout
    check_ok(dump_link_output.status, "nixos-rebuild build")?;

    let diff_output = Command::new("nvd")
        .arg("diff")
        .arg("/run/current-system")
        .arg("./result")
        .output()?;

    check_ok(diff_output.status, "nvd diff")?;
    Ok(String::from_utf8(diff_output.stdout).unwrap())
}

struct GenerationMeta {
    number: String,
    full: String,
}

/// Apply the configuration. Returns the metadata of the new generation.
fn apply_configuration(repo_path: &str) -> std::io::Result<GenerationMeta> {
    let status = Command::new("sudo")
        .arg("nixos-rebuild")
        .arg("switch")
        .arg("--flake")
        .arg(repo_path)
        .status()?;

    check_ok(status, "nixos-rebuild switch")?;

    let output = Command::new("nixos-rebuild")
        .arg("list-generations")
        .output()?;

    check_ok(output.status, "nixos-rebuild lis-generations")?;

    // list-generations returns a tsv, with the first line being the header and the second line being the current generation
    let lines = str::from_utf8(&output.stdout).unwrap().lines().take(2).collect::<Vec<_>>();

    let number = match lines.get(1) {
        Some(line) => line.split_whitespace().next().unwrap().to_string(),
        None => Err(std::io::Error::new(std::io::ErrorKind::Other, "Failed to get generation number"))?,
    };

    Ok(GenerationMeta {
        number,
        full: lines.join("\n"),
    })
}

fn make_commit(message: &str) -> Result<(), std::io::Error> {
    // This could be done with git2, but it's easier to just shell out

    let add_status = Command::new("git")
        .arg("add")
        .arg(".")
        .status()?;
    check_ok(add_status, "git add")?;

    let commit_status = Command::new("git")
        .arg("commit")
        .arg("-m")
        .arg(message)
        .status()?;
    check_ok(commit_status, "git commit")?;

    Ok(())
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let config = Config::new()?;
    let opt = Opt::parse();

    if opt.update {
        update_flake_inputs()?;
    }

    let diff = fancy_build(&config.repo_path)?;

    let metadata = apply_configuration(&config.repo_path)?;

    let full_message = format!(
        "{}#{}: {}\n\n{}\n\n{}",
        metadata.number, gethostname().to_string_lossy(), opt.commit_message,
        metadata.full,
        diff,
    );
    make_commit(&full_message)?;

    Ok(())
}
