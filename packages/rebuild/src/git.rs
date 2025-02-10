// Module for working with Git
// TODO: Could gitoxide or something similar be used instead?

use std::process::Command;

use crate::process::check_ok;

/// Stage all untracked changes, needed as untracked files are
/// not visible to Nix builds
pub fn stage_all() -> Result<(), std::io::Error> {
    let status = Command::new("git").arg("add").arg("--all").status()?;
    check_ok(status, "git add --all")
}

/// Commit staged changes with the specified message
pub fn commit(message: &str) -> Result<(), std::io::Error> {
    let commit_status = Command::new("git")
        .arg("commit")
        .arg("-m")
        .arg(message)
        .status()?;
    check_ok(commit_status, "git commit")
}

/// Pull the latest changes from the remote.
/// This is a simple wrapper around `git pull`.
/// It does not handle conflicts.
pub fn pull(repo_path: &str) -> std::io::Result<()> {
    let status = Command::new("git")
        .current_dir(repo_path)
        .arg("pull")
        .status()?;
    check_ok(status, "git pull")
}
