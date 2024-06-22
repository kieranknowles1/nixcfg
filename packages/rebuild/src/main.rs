use clap::Parser;
use core::str;
use std::process::Command;
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

fn update_flake_inputs()  {
    // TODO: Implement
}

/// Build the system with a fancy progress bar. Returns a diff between the current system and the build.
fn fancy_build() -> std::io::Result<String> {
    let status = Command::new("nh")
        .arg("os")
        .arg("build")
        .status()?;

    // We put build and diff in the same function as the diff only works after a build but
    // before a switch. This guarantees that we don't call it at the wrong time.
    match status.success() {
        true => {
            let output = Command::new("nvd")
            .arg("diff")
            .arg("/run/current-system")
            .arg("result/")
            .output()?;
            Ok(String::from_utf8(output.stdout).unwrap())
        }
        false => Err(std::io::Error::new(std::io::ErrorKind::Other, "Build failed")),
    }
}

fn apply_configuration(repo_path: &str) -> std::io::Result<()> {
    let status = Command::new("sudo")
        .arg("nixos-rebuild")
        .arg("switch")
        .arg("--flake")
        .arg(repo_path)
        .status()?;

    match status.success() {
        true => Ok(()),
        false => Err(std::io::Error::new(std::io::ErrorKind::Other, "Failed to apply configuration")),
    }
}

fn get_generation_meta() {
    // TODO: Implement
}

// fn make_commit(repo: &Repository, message: &str) {
//     // TODO: Implement
// }

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let config = Config::new()?;
    let opt = Opt::parse();

    if opt.update {
        update_flake_inputs();
    }

    let diff = fancy_build()?;

    apply_configuration(&config.repo_path)?;

    // TODO: Commit the changes

    Ok(())
}

// def get_generation_meta():
//     """
//     Get the generation number, build timestamp, etc. of the active configuration.
//     NOTE: This may fail if there are too many generations and exit with an error.
//     """

//     # We only need the first two lines
//     result = run(["nixos-rebuild", "list-generations"], check=True, capture_output=True, text=True).stdout.splitlines()[:2]

//     meta = "\n".join(result)
//     number = result[1].split()[0]

//     class Result:
//         def __init__(self, meta: str, number: str):
//             self.meta = meta
//             self.number = number
//     return Result(meta, number)

// def main():
//     arguments = Arguments.from_cli()

//     if arguments.update:
//         update_flake_inputs()

//     fancy_build()

//     # We need to do this before applying the configuration, or we're just comparing the current system to itself
//     diff = get_diff()

//     apply_configuration()

//     generation_meta = get_generation_meta()
//     host_name = node()

//     commit_messages = [
//         arguments.message or "Rebuild system.",
//         f"{generation_meta.number}#{host_name}: {arguments.message}",
//         generation_meta.meta,
//     ] + ([diff] if arguments.diff else [])
//     combined_message = "\n\n".join(commit_messages)

//     # Commit the changes.
//     run(["git", "add", "."], check=True)
//     run(["git", "commit",
//         "-m", combined_message], check=True)
