// Module for functions used during Nix build/switch.

use std::collections::BTreeMap;
use std::path::Path;
use std::process::Command;
use std::str;

use gethostname::gethostname;
use serde::Deserialize;
use thiserror::Error;

use crate::process::check_ok;

#[derive(Debug, Error)]
pub enum ListHostsError {
    #[error(transparent)]
    Io(#[from] std::io::Error),
    #[error(transparent)]
    Json(#[from] serde_json::Error),
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct FlakeShowOutput {
    // Using a BTreeMap to have a well-defined order of keys.
    nixos_configurations: BTreeMap<String, serde::de::IgnoredAny>,
}

pub fn list_hosts(flake: &Path) -> Result<Vec<String>, ListHostsError> {
    let output = Command::new("nix")
        .current_dir(flake)
        .arg("flake")
        .arg("show")
        .arg("--json")
        .output()?;
    check_ok(output.status, "nix flake show")?;

    let json: FlakeShowOutput = serde_json::from_slice(&output.stdout)?;

    Ok(json.nixos_configurations.keys().cloned().collect())
}

pub fn update_flake_inputs() -> std::io::Result<()> {
    let status = Command::new("nix").arg("flake").arg("update").status()?;

    check_ok(status, "nix flake update")
}

/// Build the system with a fancy progress bar. Returns a diff between the current system and the build.
pub fn fancy_build(repo_path: &Path) -> std::io::Result<String> {
    let build_status = Command::new("nh")
        .arg("os")
        .arg("build")
        .arg(repo_path)
        .status()?;

    // We put build and diff in the same function as the diff only works after a build but
    // before a switch. This guarantees that we don't call it at the wrong time.
    check_ok(build_status, "nh os build")?;

    // nixos-rebuild doesn't have anything to do since we've already built the system
    // it will link the new generation to ./result for us to diff
    let dump_link_output = Command::new("nixos-rebuild")
        .arg("build")
        .arg("--flake")
        .arg(repo_path)
        .output()?; // We use output to suppress stdout
    check_ok(dump_link_output.status, "nixos-rebuild build")?;

    let diff_output = Command::new("nvd")
        .arg("diff")
        .arg("/run/current-system")
        .arg("./result")
        .output()?;

    check_ok(diff_output.status, "nvd diff")?;
    Ok(String::from_utf8(diff_output.stdout).unwrap())
}

pub struct GenerationMeta {
    number: String,
    full: String,
}

impl GenerationMeta {
    pub fn to_commit_message(&self, diff: &str, commit_message: &str) -> String {
        format!(
            "{}#{}: {}\n\n{}\n\n{}",
            self.number,
            gethostname().to_string_lossy(),
            commit_message,
            self.full,
            diff,
        )
    }
}

/// Apply the configuration. Returns the metadata of the new generation.
/// No BuildToken here as nixos-rebuild produces the same output, just without the fancy bits.
pub fn apply_configuration(repo_path: &Path) -> std::io::Result<GenerationMeta> {
    let status = Command::new("sudo")
        .arg("nixos-rebuild")
        .arg("switch")
        .arg("--flake")
        .arg(repo_path)
        .status()?;

    check_ok(status, "nixos-rebuild switch")?;

    let output = Command::new("nixos-rebuild")
        .arg("list-generations")
        .output()?;

    check_ok(output.status, "nixos-rebuild lis-generations")?;

    // list-generations returns a tsv, with the first line being the header and the second line being the current generation
    let lines = str::from_utf8(&output.stdout)
        .unwrap()
        .lines()
        .take(2)
        .collect::<Vec<_>>();

    let number = match lines.get(1) {
        Some(line) => line.split_whitespace().next().unwrap().to_string(),
        None => Err(std::io::Error::new(
            std::io::ErrorKind::Other,
            "Failed to get generation number",
        ))?,
    };

    Ok(GenerationMeta {
        number,
        full: lines.join("\n"),
    })
}
