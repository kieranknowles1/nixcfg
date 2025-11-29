// Module for functions used during Nix build/switch.

use std::path::Path;
use std::process::Command;
use std::str;

use gethostname::gethostname;

use crate::process::{TempLink, check_ok};

pub fn update_flake_inputs() -> std::io::Result<()> {
    let status = Command::new("nix").arg("flake").arg("update").status()?;

    check_ok(status, "nix flake update")
}

pub fn build_output(flake: &Path, target: &str, out_link: &Path) -> std::io::Result<()> {
    // Run in `nom`, a wrapper that gives a fancy progress indicator
    let status = Command::new("nom")
        .current_dir(flake)
        .arg("build")
        .arg(target)
        .arg("--out-link")
        .arg(out_link)
        .status()?;

    check_ok(status, "nom build")
}

pub fn diff_systems(old: &Path, new: &Path) -> std::io::Result<String> {
    let diff = Command::new("nvd").arg("diff").arg(old).arg(new).output()?;
    check_ok(diff.status, "nvd diff")?;
    Ok(String::from_utf8(diff.stdout).unwrap())
}

/// Build the system with a fancy progress bar. Returns a diff between the current system and the build.
pub fn fancy_build(flake: &Path) -> std::io::Result<String> {
    let result = TempLink::new()?;
    let target = format!(
        ".#nixosConfigurations.{}.config.system.build.toplevel",
        gethostname().to_string_lossy()
    );
    build_output(flake, &target, &result.path())?;

    let diff = diff_systems(Path::new("/run/current-system"), &result.path())?;
    println!("{diff}");
    Ok(diff)
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

pub fn switch_configuration(repo_path: &Path) -> std::io::Result<()> {
    // TODO: Can we switch to ./result directly
    let status = Command::new("sudo")
        .arg("nixos-rebuild")
        .arg("switch")
        .arg("--flake")
        .arg(repo_path)
        .status()?;

    check_ok(status, "nixos-rebuild switch")
}

/// Apply the configuration. Returns the metadata of the new generation.
/// No BuildToken here as nixos-rebuild produces the same output, just without the fancy bits.
pub fn apply_configuration(repo_path: &Path) -> std::io::Result<GenerationMeta> {
    switch_configuration(repo_path)?;

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
        None => Err(std::io::Error::other("Failed to get generation number"))?,
    };

    Ok(GenerationMeta {
        number,
        full: lines.join("\n"),
    })
}
