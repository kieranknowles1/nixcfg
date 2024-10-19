mod activate;
mod config;

use std::process::ExitCode;

use clap::Parser;

type Result<T> = activate::Result<T>;

#[derive(Parser)]
enum Opt {
    Activate(activate::Opt),
}

fn main() -> Result<ExitCode> {
    let any_errors = match Opt::parse() {
        Opt::Activate(args) => activate::run(args)?,
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
