// cSpell: words gethostname nixos

use clap::{Parser, Subcommand};
use core::str;
use std::{
    fs,
    path::{Path, PathBuf},
};

mod git;
mod nix;
mod process;

/// Command-line options.
#[derive(Parser)]
struct Opt {
    #[clap(short, long, env)]
    /// The path to the flake repository.
    flake: PathBuf,

    #[clap(subcommand)]
    action: Action,
}

#[derive(Subcommand)]
enum Action {
    /// Build the system from source and commit the changes.
    Build(BuildOpt),
    /// Update flake inputs and commit the changes.
    Update(UpdateOpt),
    /// Pull the latest changes and switch to them.
    Pull(PullOpt),
}

#[derive(Parser)]
struct BuildOpt {
    /// Message to commit the changes with. Multiple arguments will be joined as
    /// separate paragraphs, similar to multiple `-m` arguments to `git commit`.
    message: Vec<String>,
}

#[derive(Parser)]
struct UpdateOpt {
    #[arg(default_value = "Update flake inputs")]
    message: String,
}

#[derive(Parser)]
struct PullOpt {}

impl BuildOpt {
    fn run(&self, flake: &Path) -> Result<(), std::io::Error> {
        git::stage_all()?;
        let msg = build_and_switch(&flake, &self.message.join("\n\n"))?;
        git::commit(&msg)
    }
}

impl UpdateOpt {
    fn run(&self, flake: &Path) -> Result<(), std::io::Error> {
        nix::update_flake_inputs()?;
        git::stage_all()?;
        let msg = build_and_switch(&flake, &self.message)?;
        git::commit(&msg)
    }
}

impl PullOpt {
    fn run(&self, flake: &Path) -> Result<(), std::io::Error> {
        git::pull(&flake)?;
        build_and_switch(&flake, "Pull latest changes")?;
        Ok(())
    }
}

fn diff_path(repo_path: &Path) -> PathBuf {
    repo_path.join(".rebuild-diff")
}

fn store_diff(repo_path: &Path, diff: &str) -> std::io::Result<()> {
    fs::write(diff_path(repo_path), diff)
}

/// Build the latest configuration and switch to it
/// Returns the provided message, generation number, and diff of the build
/// formatted for a commit message
fn build_and_switch(repo_path: &Path, message: &str) -> std::io::Result<String> {
    let diff = nix::fancy_build(repo_path)?;
    let meta = nix::apply_configuration(repo_path);

    match meta {
        Ok(meta) => {
            let commit_message = meta.to_commit_message(&diff, message);
            Ok(commit_message)
        }
        Err(e) => {
            eprintln!(
                "Build succeeded, but activation failed. Storing diff in {}",
                diff_path(repo_path).display()
            );
            store_diff(repo_path, &diff)?;
            Err(e)
        }
    }
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let opt = Opt::parse();

    println!("Using flake repository at '{}'. ", &opt.flake.display());

    let status = match opt.action {
        Action::Build(value) => value.run(&opt.flake),
        Action::Update(value) => value.run(&opt.flake),
        Action::Pull(value) => value.run(&opt.flake),
    };

    match status {
        Ok(_) => {
            println!("Successfully built, applied, and committed configuration");
            Ok(())
        }
        Err(e) => {
            eprintln!("Error running a Git or Nix command: {}", e);
            Err(Box::new(e))
        }
    }
}
