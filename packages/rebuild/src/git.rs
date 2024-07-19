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

pub enum WrapError<WrappedError> {
    /// There was an error with git, and manual intervention is advised
    GitError(std::io::Error),
    /// There was an error with the wrapped function
    WrappedError(WrappedError),
}

/// Commit all unstaged changes and run a function.
/// If the function returns an error, the commit is reverted.
/// If the function returns Ok, the commit is finalized with the returned message.
/// Intended for Nix commands as Nix complains if the repository is dirty.
pub fn wrap_in_commit<Func, Error>(
    func: Func,
) -> Result<(), WrapError<Error>> where
    Func: FnOnce() -> Result<String, Error>,
{
    match make_staging_commit() {
        Err(e) => return Err(WrapError::GitError(e)),
        Ok(_) => (),
    }

    let message = match func() {
        Ok(message) => message,
        Err(e) => {
            match reset_commit() {
                Ok(_) => return Err(WrapError::WrappedError(e)),
                Err(e) => return Err(WrapError::GitError(e)),
            }
        }
    };

    match finalize_commit(&message) {
        Ok(_) => Ok(()),
        Err(e) => Err(WrapError::GitError(e)),
    }
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
