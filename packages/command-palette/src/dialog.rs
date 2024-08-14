use std::process::Command;

use thiserror::Error;

use crate::data::{self, CommandList};

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Error, Debug)]
pub enum Error {
    #[error("I/O error {0}")]
    Io(#[from] std::io::Error),
    #[error("Operation cancelled")]
    Cancelled,
}

/// Show a dialog box with the given commands.
/// Returns the selected command.
pub fn show_choices(commands: &CommandList) -> Result<data::Command> {
    let mut zenity = Command::new("zenity");
    zenity
        .arg("--list")
        // The first column is the action, print it but don't show it to the user.
        .arg("--hide-column=1").arg("--print-column=1")
        .arg("--column=Index").arg("--column=Description");

    for (i, command) in commands.iter().enumerate() {
        zenity.arg(i.to_string()).arg(&command.description);
    }

    let output = zenity.output()?;

    match output.status.success() {
        true => {
            // Zenity prints the chosen row to stdout. This should always be valid UTF-8.
            let index = String::from_utf8(output.stdout).unwrap();
            let index = index.trim().parse::<usize>().unwrap();

            Ok(commands[index].clone())
        },
        false => {
            // Assume the user cancelled the dialog. No stderr expected.
            Err(Error::Cancelled)
        }
    }
}

pub enum MessageKind {
    Info,
    Error,
}

pub fn show_message(message: &str, kind: MessageKind) -> std::io::Result<()> {
    let kind_arg = match kind {
        MessageKind::Info => "--info",
        MessageKind::Error => "--error",
    };

    Command::new("zenity")
        .arg(kind_arg).arg("--text").arg(message)
        .status()
        .map(|_| ()) // Don't care about the status.
}
