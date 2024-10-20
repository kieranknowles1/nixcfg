mod activate;
mod config;
mod restore;

use std::process::ExitCode;

use clap::Parser;
use thiserror::Error;

#[derive(Error, Debug)]
enum Error {
    #[error("Activate error: {0}")]
    Activate(#[from] activate::Error),
    #[error("Restore error: {0}")]
    Restore(#[from] restore::Error),
}

type Result<T> = std::result::Result<T, Error>;

// [[../../../docs/plan/activate-mutable.md]]
// TODO: V2: Restore files to repo
// TODO: V3: Support directories

#[derive(Parser)]
enum Opt {
    Activate(activate::Opt),
    Restore(restore::Opt),
}

fn main() -> Result<ExitCode> {
    let any_errors = match Opt::parse() {
        Opt::Activate(args) => activate::run(args)?,
        Opt::Restore(args) => restore::run(args)?,
    };

    // If any errors occurred, return a non-zero exit code.
    let code = match any_errors {
        // Exit codes are not standardized, closest I could find were those in sysexits.h.
        // code 74 is EX_IOERR, which seems the closest to "file conflict".
        true => ExitCode::from(74),
        false => ExitCode::SUCCESS,
    };

    Ok(code)
}
