mod activate;
mod config;
mod info;
mod repo;
mod state;

use std::process::ExitCode;

use clap::Parser;

#[derive(Parser)]
enum Opt {
    /// Deploy a set of files to the system.
    Activate(activate::Opt),
    /// Copy local changes to the repository.
    #[clap(alias = "pull")]
    Repo(repo::Opt),
    /// List currently deployed files.
    #[clap(alias = "status")]
    Info(info::Opt),
}

fn main() -> Result<ExitCode, Box<dyn std::error::Error>> {
    let any_errors = match Opt::parse() {
        Opt::Activate(args) => activate::run(&args)?,
        Opt::Repo(args) => {
            repo::run(&args)?;
            false
        }
        Opt::Info(args) => {
            info::run(&args)?;
            false
        }
    };

    // If any errors occurred, return a non-zero exit code.
    let code = if any_errors {
        // Exit codes are not standardized, closest I could find were those in sysexits.h.
        // code 74 is EX_IOERR, which seems the closest to "file conflict".
        ExitCode::from(74)
    } else {
        ExitCode::SUCCESS
    };

    Ok(code)
}
