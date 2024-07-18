// Module for working with Git

use std::process::Command;

use crate::process::check_ok;

/// Make a temporary commit to stage changes.
/// Required as rebuild doesn't include untracked files and complains if there are uncommitted changes.
fn make_staging_commit() -> std::io::Result<()> {
    // This could be done with git2, but it's easier to just shell out

    let add_status = Command::new("git")
        .arg("add")
        .arg(".")
        .status()?;
    check_ok(add_status, "git add")?;

    let commit_status = Command::new("git")
        .arg("commit")
        .arg("-m")
        .arg("Temporary rebuild commit")
        .status()?;
    check_ok(commit_status, "git commit")?;

    Ok(())
}

/// Amend the latest commit with the given message.
fn finalize_commit(message: &str) -> Result<(), std::io::Error> {
    let commit_status = Command::new("git")
        .arg("commit")
        .arg("--amend")
        .arg("-m")
        .arg(message)
        .status()?;
    check_ok(commit_status, "git commit --amend")
}

/// Reset the repository to the previous commit. Does not touch the working directory
/// meaning that the changes exist but are not staged.
/// Useful for cleaning up after a failed build.
fn reset_commit() -> Result<(), std::io::Error> {
    let status = Command::new("git")
        .arg("reset")
        .arg("HEAD~")
        .status()?;
    check_ok(status, "git reset --soft HEAD^")
}


pub enum WrapStatus<Error> {
    /// The function ran successfully
    Ok,
    /// There was an error with git, and manual intervention is advised
    GitError(std::io::Error),
    /// There was an error with the wrapped function
    WrappedError(Error),
}

/// Commit all unstaged changes and run a function.
/// If the function returns an error, the commit is reverted.
/// If the function returns Ok, the commit is finalized with the returned message.
/// Intended for Nix commands as Nix complains if the repository is dirty.
/// # Returns
/// * `Ok` if the function ran successfully
/// * `GitError` if there was an error with Git
/// * `WrappedError` if there was an error with the wrapped function
pub fn wrap_in_commit<Func, Error>(
    func: Func,
) -> WrapStatus<Error> where
    Func: FnOnce() -> Result<String, Error>,
    Error: std::error::Error,
{
    match make_staging_commit() {
        Err(e) => return WrapStatus::GitError(e),
        Ok(_) => (),
    }

    match func() {
        Ok(message) => {
            match finalize_commit(&message) {
                Ok(_) => WrapStatus::Ok,
                Err(e) => WrapStatus::GitError(e),
            }
        },
        Err(e) => {
            match reset_commit() {
                Ok(_) => WrapStatus::WrappedError(e),
                Err(e) => WrapStatus::GitError(e),
            }
        }
    }
}
