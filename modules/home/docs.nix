# Module to include generated documentation for the flake and its options
{
  self,
  pkgs,
  lib,
  config,
  ...
}: {
  options.custom.docs-generate = let
    inherit (lib) mkEnableOption mkOption types options;
  in {
    enable = mkEnableOption "generate documentation for the flake and its options.";

    file = mkOption {
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

      type = types.attrsOf (types.submodule {
        options = {
          description = mkOption {
            description = "A brief, one-line description of the file.";
            type = types.str;
            example = "Options for home-manager";
          };

          source = mkOption {
            description = "The file containing the content or a string literal.";
            type = with types; oneOf [path str];
            example = options.literalExpression "./docs-generated/file-a.md";
          };
        };
      });
    };

    build = {
      generated = mkOption {
        type = types.path;
        readOnly = true;
        description = "The path to the generated documentation.";
      };
      # TODO: Use this to generate HTML documentation
      all = mkOption {
        type = types.package;
        readOnly = true;
        description = "All documentation files, generated and static. In Markdown format.";
      };

      html = mkOption {
        type = types.package;
        readOnly = true;
        description = "All documentation files, generated and static. In HTML format.";
      };
    };
  };

  config = lib.mkIf config.custom.docs-generate.enable {
    custom.docs-generate = {
      file = let
        inherit (self.builders.${pkgs.system}) mkOptionDocs;
      in {
        # "lib.md" = {
        #   description = "flake.lib library";
        #   # FIXME: This isn't working, it's not finding the functions
        #   source = self.lib.docs.mkFunctionDocs "${self}/lib";
        # };
        "host-options.md" = {
          description = "NixOS options";
          source = mkOptionDocs self.nixosModules.default "NixOS options";
        };
        "host-options.schema.json" = {
          description = "NixOS options schema";
          source = self.lib.docs.mkJsonSchema self.nixosModules.default (opts: opts.custom);
        };
        "user-options.md" = {
          description = "home-manager options";
          source = mkOptionDocs self.homeManagerModules.default "Home Manager options";
        };
        "user-options.schema.json" = let
          filterCustom = opts: opts.custom;
          # TODO: This is a bit of a hack, would like to have a proper way of disabling options
          # in JSON.
          filterNotHidden = opts:
            builtins.removeAttrs opts [
              # These are derived from the host's config and usually don't need to be set.
              # TODO: Can we just make them not required?
              "repoPath"
              "fullRepoPath"
            ];
        in {
          description = "home-manager options schema";
          source = self.lib.docs.mkJsonSchema self.homeManagerModules.default (opts: filterNotHidden (filterCustom opts));
        };
        # FIXME: home-manager lists a warning about packages.md not being a directory
        # This option should probably be like home.file, with different keys for plaintext and file sources
        "packages.md" = {
          description = "Flake packages";
          source = self.lib.docs.mkPackageDocs pkgs.flake;
        };
      };

      build = let
        /*
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
        * Combine all the documentation files into one. Generate the index file.
        */
        mkDocs = files: let
          fileNames = builtins.attrNames files;

          # Generate code to symlink the files
          # Easier than doing a loop in bash
          linkDocs = lib.lists.forEach fileNames (name: let
            value = files.${name};
            source =
              if builtins.isString value.source
              then pkgs.writeText "${name}" value.source
              else value.source;
          in "ln --symbolic ${source} $out/${name}");
        in
          pkgs.runCommand "merged-docs" {
            INDEX = mkIndex files;
          } ''
            mkdir -p $out
            echo "$INDEX" > $out/readme.md
            ${lib.strings.concatStringsSep "\n" linkDocs}
          '';
      in {
        generated = mkDocs config.custom.docs-generate.file;
        all =
          pkgs.runCommand "all-docs" {
            GENERATED = config.custom.docs-generate.build.generated;
            STATIC = "${self}/docs";
          } ''
            mkdir -p $out
            mkdir -p $out/generated
            cp -r $STATIC/* $out
            cp -r $GENERATED/* $out/generated
          '';

        html = self.builders.${pkgs.system}.buildStaticSite {
          name = "html-docs";
          src = config.custom.docs-generate.build.all;
        };
      };
    };

    custom.shortcuts.palette.actions = lib.singleton {
      description = "View documentation";
      # These are built from markdown where the convention is `readme.md` rather than `index.html`
      action = ["xdg-open" "${config.custom.docs-generate.build.html}/readme.html"];
    };

    home.file."${config.custom.repoPath}/docs/generated" = {
      source = config.custom.docs-generate.build.generated;
      recursive = true;
    };
  };
}
