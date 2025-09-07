use std::{process::Command, str::Utf8Error, string::FromUtf8Error};

use thiserror::Error;

#[derive(Error, Debug)]
pub enum Error {
    #[error(transparent)]
    Io(#[from] std::io::Error),
    #[error(transparent)]
    Utf8(#[from] std::string::FromUtf8Error),
}
type Result<T> = std::result::Result<T, Error>;

pub struct SearchResult {
    raw: Vec<u8>,
    indices: Vec<usize>,
}

impl SearchResult {
    pub fn num_entries(&self) -> usize {
        self.indices.len() - 1
    }

    pub fn entry(&self, index: usize) -> std::result::Result<&str, Utf8Error> {
        let start = self.indices[index];
        let end = self.indices[index + 1];
        std::str::from_utf8(&self.raw[start..end])
    }
}

pub fn search(query: &str) -> Result<SearchResult> {
    let raw = Command::new("fd")
        .arg("--full-path")
        .arg(query)
        .output()?
        .stdout;

    // Very basic heuristic: Assume an average line length of 80 characters
    // wordcount --chars / wordcount --lines returned 100 for my home directory,
    // overallocating will use more memory than necessary, but not predicting that
    // to be a bottleneck.
    let mut indices = Vec::with_capacity(raw.len() / 80);
    indices.push(0);
    for (i, ch) in raw.iter().enumerate() {
        if *ch == b'\n' {
            indices.push(i);
        }
    }
    indices.push(raw.len());

    Ok(SearchResult { raw: raw, indices })
}
