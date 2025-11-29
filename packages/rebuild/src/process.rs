// Utilities for running subprocesses

use std::io::{Error, Result};
use std::path::PathBuf;
use std::process::ExitStatus;

use tempfile::{TempDir, tempdir};

/// Like tmpdir, but does not create the file.
/// Used as Nix refuses to overwrite an empty file/dir with an output link.
pub struct TempLink {
    parent: TempDir,
}

impl TempLink {
    pub fn new() -> Result<Self> {
        let parent = tempdir()?;
        Ok(Self { parent })
    }

    pub fn path(&self) -> PathBuf {
        self.parent.path().join("result")
    }
}

/// Check that a command ran successfully
/// Defined as "the command ran to completion and returned a 0 exit status"
/// * `status` - The exit status of the command
/// * `command` - The command that was run. Be brief and descriptive.
pub fn check_ok(status: ExitStatus, command: &str) -> Result<()> {
    match status.code() {
        Some(0) => Ok(()),
        Some(code) => Err(Error::other(format!(
            "Command '{command}' failed with exit code {code}"
        ))),
        None => Err(Error::other(format!(
            "Command '{command}' was terminated abnormally. Did you press Ctrl+C?"
        ))),
    }
}
