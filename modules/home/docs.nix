# Module to include generated documentation for the flake and its options
{
  flake,
  pkgs,
  lib,
  config,
  ...
}: let
  docsPath = "${config.custom.repoPath}/docs";

  /*
   *
  * Generate an index of the documentation files.
  */
  mkIndex = files: let
    # Get an alphabetically sorted list of the files
    fileNames = builtins.attrNames files;

    # Map the files to a markdown list of links
    links = lib.lists.forEach fileNames (name: let
      value = files.${name};
    in "- [${name}](./${name}) - ${value.description}");
    # Generate the index file
    # This is done in pure Nix because it's easier than working with bash and jq
    # This gives the same result as bash, but in a language that while I wouldn't call
    # good, is at least better than bash, a very low bar to clear.
  in ''
    # Documentation index

    This file is the index for all generated documentation files.

    ## Files
    ${lib.strings.concatStringsSep "\n" links}
  '';

  /*
   *
  * Combine all the documentation files into one. Generate the index file.
  */
  mkDocs = files: let
    fileNames = builtins.attrNames files;

    # Generate code to symlink the files
    # Easier than doing a loop in bash
    linkDocs = lib.lists.forEach fileNames (name: let
      value = files.${name};
    in "ln --symbolic ${value.source} $out/${name}");
  in
    pkgs.runCommand "merged-docs" {
      INDEX = mkIndex files;
    } ''
      mkdir -p $out
      echo "$INDEX" > $out/readme.md
      ${lib.strings.concatStringsSep "\n" linkDocs}
    '';
in {
  options.custom.docs-generate = {
    enable = lib.mkEnableOption "generate documentation for the flake and its options.";

    file = lib.mkOption {
      description = ''
        A file include in the generated documentation.

        The key is the name of the file in the output, and the value is a file containing the content.
        This file will probably be pointing to a derivation that generates the content.

        All documentation files are generated in the `docs` directory of the flake repository.
      '';

      example = {
        "file-a.md" = {
          description = "Some generated stuff";
          source = "./docs-generated/file-a.md";
        };
      };

      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          description = lib.mkOption {
            description = "A brief, one-line description of the file.";
            type = lib.types.str;
            example = "Options for home-manager";
          };

          source = lib.mkOption {
            description = "The file containing the content. Probably a derivation.";
            type = lib.types.path;
            example = "./docs-generated/file-a.md";
          };
        };
      });
    };
  };

  config = {
    custom.docs-generate.file = {
      "lib.md" = {
        description = "flake.lib library";
        source = flake.lib.docs.mkFunctionDocs ../../lib;
      };
      "host-options.md" = {
        description = "NixOS options";
        source = flake.lib.docs.mkOptionDocs ../nixos/default.nix;
      };
      "host-options.schema.json" = {
        description = "NixOS options schema";
        source = flake.lib.docs.mkJsonSchema ../nixos/default.nix (opts: opts.custom);
      };
      "user-options.md" = {
        description = "home-manager options";
        source = flake.lib.docs.mkOptionDocs ./default.nix;
      };
      "user-options.schema.json" = {
        description = "home-manager options schema";
        source = flake.lib.docs.mkJsonSchema ./default.nix (opts: opts.custom);
      };
    };

    home.file.${docsPath} = lib.mkIf config.custom.docs-generate.enable {
      source = mkDocs config.custom.docs-generate.file;
      recursive = true;
    };
  };
}
