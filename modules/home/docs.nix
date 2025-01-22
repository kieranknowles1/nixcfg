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
            # TODO: Require using a path, disallowing strings
            description = "The file containing the content or a string literal.";
            type = with types; oneOf [path str];
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
      all = mkBuildOption "All" "Markdown";
      html = mkBuildOption "All" "HTML";
    };
  };

  config = let
    cfg = config.custom.docs-generate;
  in
    lib.mkIf cfg.enable {
      custom.docs-generate = {
        build = let
          /*
          * Generate an index of the documentation files.
          */
          mkIndex = files: let
            sortedNames = let
              names = builtins.attrNames files;
            in
              lib.sort (a: b: files.${a}.description < files.${b}.description) names;

            # # Map the files to a markdown list of links
            links = lib.lists.forEach sortedNames (name: let
              value = files.${name};
            in " - [${value.description}](./${name})");
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
          generated = mkDocs cfg.file;
          all =
            pkgs.runCommand "all-docs" {
              GENERATED = cfg.build.generated;
              STATIC = "${self}/docs";
            } ''
              mkdir -p $out
              mkdir -p $out/generated
              cp -r $STATIC/* $out
              cp -r $GENERATED/* $out/generated
            '';

          html = self.builders.${pkgs.system}.buildStaticSite {
            name = "html-docs";
            src = cfg.build.all;
          };
        };

        file = let
          inherit (self.builders.${pkgs.system}) mkOptionDocs;

          mkSchema = name: module: hidden: let
            filterCustom = opts: opts.custom;
            filterNotHidden = opts: builtins.removeAttrs opts hidden;
          in {
            description = "${name} options schema";
            source = self.lib.docs.mkJsonSchema module (opts: filterNotHidden (filterCustom opts));
          };
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
          "host-options.schema.json" = mkSchema "NixOS" self.nixosModules.default cfg.jsonIgnoredOptions.nixos;
          "user-options.md" = {
            description = "Home Manager options";
            source = mkOptionDocs self.homeManagerModules.default "Home Manager options";
          };
          "user-options.schema.json" = mkSchema "Home Manager" self.homeManagerModules.default cfg.jsonIgnoredOptions.home;

          # FIXME: home-manager lists a warning about packages.md not being a directory
          # This option should probably be like home.file, with different keys for plaintext and file sources
          "packages.md" = {
            description = "Flake packages";
            source = self.lib.docs.mkPackageDocs pkgs.flake;
          };

          "flake-tree.dot" = {
            description = "Flake input tree. Converted to SVG when building HTML.";
            source = pkgs.runCommand "flake-tree.dot" {buildInputs = with pkgs; [nushell graphviz];} ''
              # Ignore standard inputs to avoid cluttering the graph
              # Chosen mostly arbitrarily
              nu ${self}/packages/nix-utils/flake-tree.nu --dot ${self}/flake.lock \
                nixpkgs systems flake-utils > $out
            '';
          };
        };
      };

      custom.shortcuts.palette.actions = lib.singleton {
        description = "View documentation";
        # These are built from markdown where the convention is `readme.md` rather than `index.html`
        action = ["xdg-open" "${cfg.build.html}/readme.html"];
      };

      home.file."${config.custom.repoPath}/docs/generated" = {
        source = cfg.build.generated;
        recursive = true;
      };
    };
}
