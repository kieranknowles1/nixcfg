# Module to include generated documentation for the flake and its options
{
  flake,
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
in {
  options.custom.docs-generate = {
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
          source = ./docs-generated/file-a.md;
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
            example = ./docs-generated/file-a.md;
          };
        };
      });
    };
  };

  config = let
    docFiles = config.custom.docs-generate.file;

    # Map the files to the correct paths. Having all docs in one option simplifies any changes I might want to make.
    # No sane language would allow an apostrophe in a variable name, but Nix is not a sane language.
    # mapAttrs' returns a set where we can change the key and value.
    homeFiles =
      lib.attrsets.mapAttrs' (name: value: {
        name = "${docsPath}/${name}";
        value = {source = value.source;};
      })
      docFiles;
  in {
    custom.docs-generate.file = {
      "lib.md" = {
        description = "flake.lib library";
        source = flake.lib.docs.mkFunctionDocs ../../lib;
      };
      "host-options.md" = {
        description = "NixOS options";
        source = flake.lib.docs.mkOptionDocs ../nixos/default.nix;
      };
      "user-options.md" = {
        description = "home-manager options";
        source = flake.lib.docs.mkOptionDocs ./default.nix;
      };
    };

    home.file =
      homeFiles
      // {
        "${docsPath}/readme.md".text = mkIndex docFiles;
      };
  };
}
