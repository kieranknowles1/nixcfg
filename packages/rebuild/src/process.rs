// Utilities for running subprocesses

use std::process::ExitStatus;
use std::io::{Result, Error, ErrorKind};

/// Check that a command ran successfully
/// Defined as "the command ran to completion and returned a 0 exit status"
/// * `status` - The exit status of the command
/// * `command` - The command that was run. Be brief and descriptive.
pub fn check_ok(status: ExitStatus, command: &str) -> Result<()> {
    match status.code() {
        Some(0) => Ok(()),
        Some(code) => Err(Error::new(
            ErrorKind::Other,
            format!("Command '{}' failed with exit code {}", command, code),
        )),
        None => Err(Error::new(
            ErrorKind::Other,
            format!("Command '{}' was terminated abnormally. Did you press Ctrl+C?", command),
        )),
    }
}
