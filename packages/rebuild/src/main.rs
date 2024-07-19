// cSpell: words gethostname nixos

use clap::Parser;
use core::str;
use std::env;

mod git;
mod nix;
mod process;

use git::{WrapError, wrap_in_commit};

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
enum Opt {
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
    fn run(&self, config: &Config) -> Result<(), WrapError<std::io::Error>> {
        wrap_in_commit(|| build_and_switch(&config.repo_path, &self.message))
    }
}

impl UpdateOpt {
    fn run(&self, config: &Config) -> Result<(), WrapError<std::io::Error>> {
        match nix::update_flake_inputs() {
            Ok(_) => (),
            Err(e) => return Err(WrapError::WrappedError(e)),
        }
        wrap_in_commit(|| build_and_switch(&config.repo_path, &self.message))
    }
}

impl PullOpt {
    fn run(&self, config: &Config) -> Result<(), WrapError<std::io::Error>> {
        match git::pull(&config.repo_path) {
            Ok(_) => (),
            Err(e) => return Err(WrapError::GitError(e)),
        }
        match build_and_switch(&config.repo_path, "Pull latest changes") {
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
    let config = Config::new()?;
    let opt = Opt::parse();

    let status = match opt {
        Opt::Build(value) => value.run(&config),
        Opt::Update(value) => value.run(&config),
        Opt::Pull(value) => value.run(&config),
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
