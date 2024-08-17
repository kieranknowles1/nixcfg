// cSpell: words gethostname nixos

use clap::{Parser, Subcommand};
use core::str;
use std::env;

mod git;
mod nix;
mod process;

use git::{WrapError, wrap_in_commit};

/// Configuration derived from the environment.
struct Config {
    /// The path to the flake repository.
    flake: String,
}

impl Config {
    fn new() -> Result<Self, env::VarError> {
        Ok(Self {
            flake: env::var("FLAKE")?,
        })
    }
}

/// Command-line options.
#[derive(Parser)]
struct Opt {
    #[clap(short, long)]
    /// The path to the flake repository. If not provided, the FLAKE environment variable is used.
    flake: Option<String>,

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
    fn run(&self, flake: &str) -> Result<(), WrapError<std::io::Error>> {
        wrap_in_commit(|| build_and_switch(&flake, &self.message))
    }
}

impl UpdateOpt {
    fn run(&self, flake: &str) -> Result<(), WrapError<std::io::Error>> {
        match nix::update_flake_inputs() {
            Ok(_) => (),
            Err(e) => return Err(WrapError::WrappedError(e)),
        }
        wrap_in_commit(|| build_and_switch(&flake, &self.message))
    }
}

impl PullOpt {
    fn run(&self, flake: &str) -> Result<(), WrapError<std::io::Error>> {
        match git::pull(&flake) {
            Ok(_) => (),
            Err(e) => return Err(WrapError::GitError(e)),
        }
        match build_and_switch(&flake, "Pull latest changes") {
            Ok(_) => Ok(()),
            Err(e) => Err(WrapError::WrappedError(e)),
        }
    }
}

fn build_and_switch(repo_path: &str, message: &str) -> std::io::Result<String> {
    let diff = nix::fancy_build(repo_path)?;
    let meta = nix::apply_configuration(repo_path)?;

    let commit_message = meta.to_commit_message(&diff, message);

    Ok(commit_message)
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let opt = Opt::parse();

    let flake = match opt.flake {
        Some(value) => value,
        None => {
            match Config::new() {
                Ok(config) => config.flake,
                Err(e) => {
                    eprintln!("FLAKE environment variable not set. Use the --flake option or set the FLAKE environment variable.");
                    return Err(Box::new(e));
                },
            }
        }
    };

    print!("Using flake repository at '{}'. ", flake);

    let status = match opt.action {
        Action::Build(value) => value.run(&flake),
        Action::Update(value) => value.run(&flake),
        Action::Pull(value) => value.run(&flake),
    };

    match status {
        Ok(_) => {
            println!("Successfully built, applied, and committed configuration");
            Ok(())
        },
        Err(WrapError::WrappedError(e)) => {
            eprintln!("Failed to build or apply configuration: {}", e);
            Err(Box::new(e))
        },
        Err(WrapError::GitError(e)) => {
            eprintln!("A Git command failed. The repository may have been altered by this script. Please check the repository and fix any issues manually.");
            Err(Box::new(e))
        },
    }
}
