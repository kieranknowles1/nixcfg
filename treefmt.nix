# Config for treefmt. This is a Nix module, and as such has all
# the features of one.
# See https://flake.parts/options/treefmt-nix for a list of options
#
# NOTE: After changing formatter options, run `nix fmt -- --clear-cache` to
# force a reformat of all files
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
      pkgs,
      config,
      ...
    }: {
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
        cmake-format.enable = true; # CMake
        rustfmt.enable = true; # Rust
        stylua.enable = true; # Lua

        # Like prettier, but written in memory-safe Rust
        # rather than JavaScript with it's garbage collection (ew)
        deno = {
          enable = true;

          # Be explicit about what Deno should format
          includes = lib.mkForce [
            "*.css"
            "*.json"
            "*.md"
          ];
        };

        php-cs-fixer = {
          enable = true;
          configFile = ./.php-cs-fixer.php;
          package = pkgs.stable.phpPackages.php-cs-fixer;
        };

        taplo.enable = true; # TOML

        yamlfmt.enable = true; # YAML

        # Static analysis
        shellcheck.enable = true; # Bash

        deadnix.enable = true; # Nix
        statix = {
          # Nix
          enable = true;
          disabled-lints = [
            # !boolOrString is different to boolOrString != false
            "bool_comparison"
          ];
        };

        # Other Repositories
        # These languages are not used in this repository, but their formatters are included
        # to let me use the same config everywhere
        gdformat.enable = true; # GDScript

        clang-format.enable = true; # C++
      };

      # Formatters not included in the treefmt-nix repo
      settings.formatter = {
        phpstan = {
          command = lib.getExe pkgs.php84Packages.phpstan;
          options = [
            "analyze"
            "--level=max"
            "--no-interaction"
            "--autoload-file=${config.programs.php-cs-fixer.package}/share/php/php-cs-fixer/vendor/autoload.php"
          ];
          includes = ["*.php"];
        };
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
