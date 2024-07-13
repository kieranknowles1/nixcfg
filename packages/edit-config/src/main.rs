use std::borrow::Borrow;
use config::Config;
use clap::Parser;

mod config;

#[derive(Parser)]
struct Args {
    /// The program to configure
    program: String,
}

/// Error for when a program is not found in the config
#[derive(Debug, Clone)]
struct ProgramNotFoundError {
    program: String,
}
impl std::fmt::Display for ProgramNotFoundError {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "Program not found: {}", self.program)
    }
}
impl std::error::Error for ProgramNotFoundError {}

fn get_config() -> Result<Config, Box<dyn std::error::Error>> {
    let config_path = shellexpand::tilde("~/.config/edit-config.json");
    let config_path_borrow: &str = config_path.borrow();

    let config_str = std::fs::read_to_string(config_path_borrow)?;

    Ok(Config::from_str(&config_str)?)
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let config = get_config()?;
    let args = Args::parse();

    let program = match config.programs.get(&args.program) {
        Some(program) => program,
        None => Err(ProgramNotFoundError { program: args.program })?,
    };

    Ok(())
}
