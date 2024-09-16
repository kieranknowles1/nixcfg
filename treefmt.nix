# Config for treefmt. This is a Nix module, and as such has all
# the features of one.
# See https://flake.parts/options/treefmt-nix for a list of options
{lib, ...}: {
  projectRootFile = "flake.nix";

  settings.global = {
    excludes = [
      "**/Cargo.toml" # Managed by the Cargo command
      "**/espanso/config/match/packages/**" # Externally sourced
      "**/factorio/blueprints/**" # Generated from blueprint-storage.dat, not meant to be edited
      # Plain text from ~/.ssh
      "**/ssh/hosts/**"
      "**/ssh/keys/**"

      # Binary files
      "*.heic"
      "*.jpg"
      "*.odp"
      "*.ods"
      "*.odt"
    ];
  };

  programs = {
    alejandra.enable = true; # Nix
    beautysh.enable = true; # Bash
    black.enable = true; # Python
    rustfmt.enable = true; # Rust
    stylua.enable = true; # Lua

    prettier = {
      enable = true;

      includes = lib.mkForce [
        "*.md"
        "*.json"
      ];
    };

    # Static analysis
    deadnix.enable = true; # Nix
  };
}
