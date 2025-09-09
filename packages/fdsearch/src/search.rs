use std::{
    path::PathBuf,
    process::{Command, ExitStatus},
    str::Utf8Error,
};

use thiserror::Error;

#[derive(Error, Debug)]
pub enum Error {
    #[error(transparent)]
    Io(#[from] std::io::Error),
    #[error(transparent)]
    Utf8(#[from] std::string::FromUtf8Error),
    #[error("fd command failed ({code}):\n{message}")]
    FdFailed { code: ExitStatus, message: String },
}
type Result<T> = std::result::Result<T, Error>;

pub struct SearchResult {
    raw: Vec<u8>,
    // Indices of the first byte of each entry into raw, defined as the next byte
    // after a null terminator
    indices: Vec<usize>,
}
pub type QueryResult = Result<SearchResult>;

impl SearchResult {
    pub fn num_entries(&self) -> usize {
        self.indices.len() - 1
    }

    pub fn entry(&self, index: usize) -> std::result::Result<&str, Utf8Error> {
        let start = self.indices[index];
        // -1 to exclude the null terminator
        let end = self.indices[index + 1] - 1;
        std::str::from_utf8(&self.raw[start..end])
    }
}

pub fn search(base: &PathBuf, query: &str) -> QueryResult {
    let out = Command::new("fd")
        // Unix filenames can contain new lines, blame John Unix
        .arg("--print0")
        .arg("--full-path")
        .arg(query)
        .arg(base)
        .output()?;

    let raw = match out.status.success() {
        true => out.stdout,
        false => {
            return Err(Error::FdFailed {
                code: out.status,
                // If the error message is not UTF-8, we're really fucked
                message: String::from_utf8(out.stderr).unwrap(),
            });
        }
    };

    // Very basic heuristic: Assume an average line length of 80 characters
    // wordcount --chars / wordcount --lines returned 100 for my home directory,
    // overallocating will use more memory than necessary, but not predicting that
    // to be a bottleneck.
    let mut indices = Vec::with_capacity(raw.len() / 80);
    indices.push(0);
    for (i, ch) in raw.iter().enumerate() {
        if *ch == 0 {
            // The next entry starts after the null terminator
            indices.push(i + 1);
        }
    }
    // No need to push a final index, as fd prints null at the end
    // indices.push(raw.len());

    Ok(SearchResult { raw: raw, indices })
}
