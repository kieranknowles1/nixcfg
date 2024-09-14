# Config for treefmt. This is a Nix module, and as such has all
# the features of one.
# See https://flake.parts/options/treefmt-nix for a list of options
{...}: {
  projectRootFile = "flake.nix";

  settings.global = {
    excludes = [
      "**/Cargo.toml" # Managed by the Cargo command
      "**/espanso/config/match/packages/**" # Externally sourced
      "**/factorio/blueprints/**" # Generated from blueprint-storage.dat, not meant to be edited
      # Plain text from ~/.ssh
      "**/ssh/hosts/**"
      "**/ssh/keys/**"
    ];
  };

  programs = {
    alejandra.enable = true; # Nix

    black.enable = false; # Python

    rustfmt.enable = true; # Rust

    stylua.enable = true; # Lua
  };
}
