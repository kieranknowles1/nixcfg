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

impl BuildOpt {
    fn run(&self, config: &Config) -> Result<(), WrapError<Box<dyn std::error::Error>>> {
        wrap_in_commit(|| build_and_switch(&config.repo_path, &self.message))
    }
}

impl UpdateOpt {
    fn run(&self, config: &Config) -> Result<(), WrapError<Box<dyn std::error::Error>>> {
        match nix::update_flake_inputs() {
            Ok(_) => (),
            Err(e) => return Err(WrapError::WrappedError(Box::new(e))),
        }
        wrap_in_commit(|| build_and_switch(&config.repo_path, &self.message))
    }
}

fn build_and_switch(repo_path: &str, message: &str) -> Result<String, Box<dyn std::error::Error>> {
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
    };

    match status {
        Ok(_) => {
            println!("Successfully built, applied, and committed configuration");
            Ok(())
        },
        Err(WrapError::WrappedError(e)) => {
            eprintln!("Failed to build or apply configuration: {}", e);
            Err(e)
        },
        Err(WrapError::GitError(e)) => {
            eprintln!("A Git command failed. The repository may have been altered by this script. Please check the repository and fix any issues manually.");
            Err(Box::new(e))
        },
    }
}
