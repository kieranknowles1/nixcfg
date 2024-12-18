# Config for treefmt. This is a Nix module, and as such has all
# the features of one.
# See https://flake.parts/options/treefmt-nix for a list of options
{
  lib,
  inputs,
  ...
}: let
  flakeModule = {
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

          # Be explicit about what Deno should format
          includes = lib.mkForce [
            "*.md"
            "*.json"
          ];
        };

        yamlfmt.enable = true; # YAML

        # Static analysis
        shellcheck.enable = true; # Bash

        deadnix.enable = true; # Nix
        statix.enable = true; # Nix

        # Other Repositories
        # These languages are not used in this repository, but their formatters are included
        # to let me use the same config everywhere
        gdformat.enable = true; # GDScript

        clang-format.enable = true; # C++
      };
    };
  };
in {
  imports = [
    # Importing a module declared by the same module causes infinite recursion,
    # so we use a `let in` block to avoid that
    # Other flakes can still use the `flakeModule` attribute for an identical config
    flakeModule
  ];

  flake.flakeModules.treefmt = flakeModule;

  perSystem.treefmt = {
    # Excludes specific to this project
    settings.global.excludes = [
      # Plain text from ~/.ssh
      "**/ssh/hosts/**"
      "**/ssh/keys/**"
    ];
  };
}
