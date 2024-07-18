// cSpell: words gethostname nixos

use clap::Parser;
use core::str;
use std::env;

mod git;
mod nix;
mod process;

use git::{WrapStatus, wrap_in_commit};

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
    Build {
        message: String,
    },
    /// Update flake inputs and commit the changes.
    Update {
        #[arg(default_value = "Update flake inputs")]
        message: String,
    },
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let config = Config::new()?;
    let opt = Opt::parse();

    let commit_message = match opt {
        Opt::Build { message } => message,
        Opt::Update { message } => {
            nix::update_flake_inputs()?;
            message
        }
    };

    let status: WrapStatus<std::io::Error> = wrap_in_commit(|| {
        let diff = nix::fancy_build(&config.repo_path)?;
        let meta = nix::apply_configuration(&config.repo_path)?;

        Ok(meta.to_commit_message(&diff, &commit_message))
    });
        // || build_and_switch(&config.repo_path, &commit_message),
    // );

    match status {
        WrapStatus::Ok => {
            println!("Successfully built, applied, and committed configuration");
            Ok(())
        },
        WrapStatus::GitError(e) => {
            eprintln!("A Git command failed. The repository may have been altered by this script. Please check the repository and fix any issues manually.");
            Err(Box::new(e))
        },
        WrapStatus::WrappedError(e) => {
            eprintln!("Failed to build and apply configuration: {}", e);
            Err(Box::new(e))
        },
    }
}
