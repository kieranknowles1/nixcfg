use serde::Deserialize;
use thiserror::Error;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Error, Debug)]
pub enum Error {
    #[error("I/O error {0}")]
    Io(#[from] std::io::Error),
    #[error("JSON error {0}")]
    Json(#[from] serde_json::Error),
}

#[derive(Deserialize, Clone)]
// Be strict and error if we don't recognize a field.
#[serde(deny_unknown_fields)]
pub struct Command {
    /// The command to run. The first element is the command, the rest are arguments.
    pub action: Vec<String>,
    /// A human-readable description of the command.
    pub description: String,
}

pub type CommandList = Vec<Command>;

pub fn from_file(file: &str) -> Result<CommandList> {
    let file = std::fs::File::open(file)?;
    let data: CommandList = serde_json::from_reader(file)?;

    Ok(data)
}
