use clap::error::Result;
use clap::{Parser, Subcommand, Args};
use std::process;
use std::env;
use git2::Repository;

#[derive(Parser)]
struct Cli {
    #[command(subcommand)]
    command: Command,
}

#[derive(Subcommand, Clone)]
enum Command {
    /// Rebuild the system from the current repository state and commit the changes if successful.
    Rebuild(RebuildArgs),
    /// Update the flake inputs before rebuilding the system.
    Update(UpdateArgs),
    /// Pull the latest changes from the repository and rebuild the system.
    Pull(PullArgs),
}

#[derive(Args, Clone)]
struct RebuildArgs {
    message: String,
}

#[derive(Args, Clone)]
struct UpdateArgs {
    #[arg(default_value = "Update flake inputs.")]
    message: String,
}

#[derive(Args, Clone)]
struct PullArgs {}

fn main() -> std::io::Result<()> {
    let args = Cli::parse();

    args.command.run()?;

    Ok(())
}

impl Command {
    fn run(&self) -> std::io::Result<()> {
        match self {
            Command::Rebuild(args) => args.run(),
            Command::Update(args) => args.run(),
            Command::Pull(args) => args.run(),
        }
    }
}

impl RebuildArgs {
    fn run(&self) -> std::io::Result<()> {
        // TODO: Implement
        fancy_build()?;

        Ok(())
    }
}

impl UpdateArgs {
    fn run(&self) -> std::io::Result<()> {
        // TODO: Implement
        fancy_build()?;

        Ok(())
    }
}

impl PullArgs {
    fn run(&self) -> std::io::Result<()> {
        // TODO: Implement
        fancy_build()?;

        Ok(())
    }
}

fn get_repo() -> Result<Repository, git2::Error> {
    let path = env::
}

fn fancy_build() -> std::io::Result<()> {
    let mut process = process::Command::new("nh")
        .arg("os")
        .arg("build")
        .spawn()?;

    let result = process.wait()?;

    match result.code() {
        Some(0) => Ok(()),
        Some(code) => Err(std::io::Error::new(std::io::ErrorKind::Other, format!("Process exited with code {}", code))),
        None => Err(std::io::Error::new(std::io::ErrorKind::Other, "Process failed with no exit code")),
    }
}


// #!/usr/bin/env python3

// from argparse import ArgumentParser, Namespace
// from subprocess import run
// from os import geteuid

// def update_flake_inputs():
//     """Update the flake inputs."""
//     run(["nix", "flake", "update"], check=True)

// def fancy_build():
//     """Build the system with fancy progress and diff output. Uses the hostname as the build target."""
//     run(["nh", "os", "build", "."], check=True)

// def get_diff():
//     """Get a diff between the repository state and the current system. Must be run before applying the configuration."""
//     # Get a build symlinked into result/
//     run(["nixos-rebuild", "build", "--flake", "."], check=True)
//     # Generate a diff between the current system and the build
//     return run(["nvd", "diff", "/run/current-system", "result/"], check=True, capture_output=True, text=True).stdout

// def apply_configuration():
//     """Apply the configuration to the system."""
//     run(["sudo", "nixos-rebuild", "switch", "--flake", "."], check=True)

// # TODO: This doesn't currently work, list-generations throws an error
// # def get_generation_meta():
// #     """Get the generation number, build timestamp, etc. of the active configuration."""

// #     # We only need the first two lines
// #     result = run(["nixos-rebuild", "list-generations"], check=True, capture_output=True, text=True).stdout.splitlines()[:2]

// #     meta = "\n".join(result)
// #     number = result[1].split()[0]

// #     class Result:
// #         def __init__(self, meta: str, number: str):
// #             self.meta = meta
// #             self.number = number
// #     return Result(meta, number)

// def main():
//     if called_as_root():
//         raise RuntimeError("Do not run this script as root.")
//     arguments = Arguments.from_cli()

//     if arguments.update:
//         update_flake_inputs()

//     fancy_build()

//     # We need to do this before applying the configuration, or we're just comparing the current system to itself
//     diff = get_diff()

//     apply_configuration()

//     if not arguments.no_commit:
//         # generation_meta = get_generation_meta()

//         commit_messages = [
//             arguments.message or "Rebuild system.",
//             # f"{generation_meta.number}: {arguments.message}",
//             # generation_meta.meta,
//         ] + ([diff] if arguments.diff else [])
//         combined_message = "\n\n".join(commit_messages)

//         # Commit the changes.
//         run(["git", "add", "."], check=True)
//         run(["git", "commit",
//             "-m", combined_message], check=True)

// if __name__ == "__main__":
//     main()
