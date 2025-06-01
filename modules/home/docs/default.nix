# Module to include generated documentation for the flake and its options
{
  lib,
  config,
  ...
}: {
  options.custom.docs-generate = let
    inherit (lib) mkEnableOption mkOption types options;
  in {
    enable = mkEnableOption "generated documentation for the flake and its options.";

    jsonIgnoredOptions = let
      mkIgnoredOptions = name:
        mkOption {
          description = ''
            A list of ${name} options to ignore when generating a JSON schema.

            NOTE: Only top-level options of options.custom are supported. I.e., options.custom.foo works,
            but options.custom.foo.bar does not.
          '';
          type = types.listOf types.str;
          example = ["foo" "bar"];
          default = [];
        };
    in {
      nixos = mkIgnoredOptions "NixOS";
      home = mkIgnoredOptions "Home Manager";
    };

    file = mkOption {
      description = ''
        A file include in the generated documentation.

        The key is the name of the file in the output, and the value is a file containing the content.
        This file will probably be pointing to a derivation that generates the content.

        All documentation files are generated in the `docs` directory of the flake repository.

        This is passed as-is when building markdown. When building HTML, only
        markdown files are included. Make sure to replicate any information in a
        human-readable format as well as machine-readable.
      '';

      example = {
        "file-a.md" = {
          description = "Some generated stuff";
          source = "./docs-generated/file-a.md";
        };
      };

      type = types.attrsOf (types.submodule {
        options = {
          description = mkOption {
            description = "A brief, one-line description of the file.";
            type = types.str;
            example = "Options for home-manager";
          };

          dynamic = mkOption {
            description = ''
              Whether the file is dynamic, meaning it varies per-host.
            '';
            type = types.bool;
            default = false;
          };

          source = mkOption {
            description = "The file containing the content.";
            type = types.path;
            example = options.literalExpression "./docs-generated/file-a.md";
          };
        };
      });
    };

    build = let
      mkBuildOption = name: format:
        mkOption {
          type = types.package;
          readOnly = true;
          description = "${name} documentation, in ${format} format";
        };
    in {
      generated = mkBuildOption "Generated" "Markdown";
      combined = {
        markdown = mkBuildOption "Combined" "Markdown";
        html = mkBuildOption "Combined" "HTML book";
      };
    };
  };

  imports = [
    ./build.nix
    ./base.nix
  ];

  config = let
    cfg = config.custom.docs-generate;
  in
    lib.mkIf cfg.enable {
      custom.shortcuts.palette.actions = lib.singleton {
        description = "View documentation";
        # These are built from markdown where the convention is `readme.md` rather than `index.html`
        action = ["xdg-open" "${cfg.build.combined.html}/index.html"];
      };

      home.file."${config.custom.repoPath}/docs/generated" = {
        source = "${cfg.build.generated}/generated";
        recursive = true;
      };
    };
}
