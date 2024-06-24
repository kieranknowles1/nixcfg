# Module to include generated documentation for the flake and its options
{ flake, lib, config, ... }: let
  docsPath = "${config.custom.repoPath}/docs";

  /**
   * Generate an index of the documentation files.
   */
  mkIndex = files: let
    # Get an alphabetically sorted list of the files
    fileNames = builtins.attrNames files;

    links = lib.lists.forEach fileNames (name: "- [${name}](./${name})");

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
        "file-a.md" = ./docs-generated/file-a.md;
      };

      type = lib.types.attrsOf lib.types.path;
    };
  };

  config = let
    docFiles = config.custom.docs-generate.file;

    # Map the files to the correct paths. Having all docs in one option simplifies any changes I might want to make.
    # No sane language would allow an apostrophe in a variable name, but Nix is not a sane language.
    # mapAttrs' returns a set where we can change the key and value.
    homeFiles = lib.attrsets.mapAttrs' (name: value: {
      name = "${docsPath}/${name}";
      value = { source = value; };
    }) docFiles;
  in {
    custom.docs-generate.file = {
      "lib.md" = flake.lib.docs.mkFunctionDocs ../../lib;
      "host-options.md" = flake.lib.docs.mkOptionDocs ../nixos/default.nix;
      "user-options.md" = flake.lib.docs.mkOptionDocs ./default.nix;
    };

    home.file = homeFiles // {
      "${docsPath}/readme.md".text = mkIndex docFiles;
    };
  };
}
