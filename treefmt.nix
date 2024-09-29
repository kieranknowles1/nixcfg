# Config for treefmt. This is a Nix module, and as such has all
# the features of one.
# See https://flake.parts/options/treefmt-nix for a list of options
{
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem.treefmt = {
    projectRootFile = "flake.nix";

    settings.global = {
      # Treefmt raises warnings for all files not covered by a formatter,
      # so we explicitly skip files that are not meant to be formatted
      excludes = [
        "**/Cargo.toml" # Managed by the Cargo command
        "**/espanso/config/match/packages/**" # Externally sourced
        "**/factorio/blueprints/**" # Generated from blueprint-storage.dat, not meant to be edited
        # Plain text from ~/.ssh
        "**/ssh/hosts/**"
        "**/ssh/keys/**"

        # Godot scenes/resources. Managed by the editor
        "*.tscn"
        "*.tres"

        # Binary files
        "*.heic"
        "*.jpg"
        "*.odp"
        "*.ods"
        "*.odt"
        "*.png"
        "*.ttf"
        "*.wav"
      ];
    };

    programs = {
      alejandra.enable = true; # Nix
      beautysh.enable = true; # Bash
      black.enable = true; # Python
      rustfmt.enable = true; # Rust
      stylua.enable = true; # Lua

      deno = {
        enable = true;

        includes = lib.mkForce [
          "*.md"
          "*.json"
        ];
      };

      yamlfmt.enable = true; # YAML

      # Static analysis
      shellcheck.enable = true; # Bash

      deadnix.enable = true; # Nix
      statix = {
        # Nix
        enable = true;

        disabled-lints = [
          # Don't replace `a = attrs.a` with `inherit (attrs) a;`
          # as I find the assignment more readable
          # We still prefer `inherit a;` over `a = a` though
          # as I find the inheritance more readable
          "manual_inherit_from"
        ];
      };

      # Other Repositories
      # These languages are not used in this repository, but their formatters are included
      # to let me use the same config everywhere
      gdformat.enable = true; # GDScript

      clang-format.enable = true; # C++
    };
  };
}
