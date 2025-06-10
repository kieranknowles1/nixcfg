// cSpell: words gethostname nixos

use clap::{Parser, Subcommand};
use core::str;
use std::{
    env,
    path::{Path, PathBuf},
};

mod git;
mod nix;
mod process;

/// Configuration derived from the environment.
struct Config {
    /// The path to the flake repository.
    flake: PathBuf,
}

impl Config {
    fn new() -> Result<Self, env::VarError> {
        Ok(Self {
            flake: PathBuf::from(env::var("FLAKE")?),
        })
    }
}

/// Command-line options.
#[derive(Parser)]
struct Opt {
    #[clap(short, long)]
    /// The path to the flake repository. If not provided, the FLAKE environment variable is used.
    flake: Option<PathBuf>,

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
    message: String,
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
        let msg = build_and_switch(&flake, &self.message)?;
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

/// Build the latest configuration and switch to it
/// Returns the provided message, generation number, and diff of the build
/// formatted for a commit message
fn build_and_switch(repo_path: &Path, message: &str) -> std::io::Result<String> {
    let diff = nix::fancy_build(repo_path)?;
    let meta = nix::apply_configuration(repo_path)?;

    let commit_message = meta.to_commit_message(&diff, message);

    Ok(commit_message)
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let opt = Opt::parse();

    let flake = match opt.flake {
        Some(value) => value,
        None => match Config::new() {
            Ok(config) => config.flake,
            Err(e) => {
                eprintln!(
                    "FLAKE environment variable not set. Use the --flake option or set the FLAKE environment variable."
                );
                return Err(Box::new(e));
            }
        },
    };

    println!("Using flake repository at '{}'. ", flake.display());

    let status = match opt.action {
        Action::Build(value) => value.run(&flake),
        Action::Update(value) => value.run(&flake),
        Action::Pull(value) => value.run(&flake),
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
