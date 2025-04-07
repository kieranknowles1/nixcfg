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
            description = "The file containing the content or a string literal.";
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
      # Keep static docs separated to avoid rebuilding them
      # every time generated docs are rebuilt
      static = mkBuildOption "Static" "HTML";

      # It's much easier to generate Markdown as an intermediate format
      # rather than HTML directly.
      generated = {
        md = mkBuildOption "Generated" "Markdown";
        html = mkBuildOption "Generated" "HTML";
      };
      combined = mkBuildOption "Combined" "HTML";
    };
  };

  config = let
    cfg = config.custom.docs-generate;
  in
    lib.mkIf cfg.enable {
      custom.docs-generate = {
        build = let
          inherit (self.builders.${pkgs.system}) buildStaticSite;
        in {
          static = buildStaticSite {
            src = "${self}/docs";
            name = "static-docs";
          };

          generated = {
            md = let
              mkIndex = files: let
                sortedNames = let
                  names = builtins.attrNames files;
                  predicate = a: b:
                    files.${a}.description < files.${b}.description;
                in
                  lib.sort predicate names;

                # Map the files to a markdown list of links
                links = lib.lists.forEach sortedNames (name: let
                  value = files.${name};
                in " - [${value.description}](./${name})");
                # Generate the index file
                # This is done in pure Nix because it's easier than working with
                # bash and jq. This gives the same result as bash, but in a
                # language that while I wouldn't call good, is at least better
                # than bash, a very low bar to clear.
              in ''
                # Documentation index

                This file is the index for all generated documentation files.

                ## Files
                ${lib.strings.concatStringsSep "\n" links}
              '';

              /*
              * Combine all the documentation files into one plus an index file
              */
              mkDocs = files: let
                fileNames = builtins.attrNames files;

                # Generate code to symlink the files
                # Easier than doing a loop in bash
                # Note how we put everything in $out/generated, which lets us
                # symlinkjoin later
                linkDocs = lib.lists.forEach fileNames (name: let
                  value = files.${name};
                in "ln --symbolic ${value.source} $out/generated/${name}");
              in
                pkgs.runCommand "merged-docs" {
                  INDEX = mkIndex files;
                } ''
                  mkdir -p $out/generated
                  echo "$INDEX" > $out/generated/readme.md
                  ${lib.strings.concatStringsSep "\n" linkDocs}
                '';
            in
              mkDocs cfg.file;

            html = buildStaticSite {
              src = cfg.build.generated.md;
              name = "generated-docs";
            };
          };

          combined = pkgs.symlinkJoin {
            name = "combined-docs";
            paths = [cfg.build.static cfg.build.generated.html];
          };
        };

        file = let
          inherit (self.builders.${pkgs.system}) mkOptionDocs;

          mkSchema = name: module: hidden: let
            filterCustom = opts: opts.custom;
            filterNotHidden = opts: builtins.removeAttrs opts hidden;

            text = self.lib.docs.mkJsonSchema module (opts: filterNotHidden (filterCustom opts));
          in {
            description = "${name} options schema";
            source = pkgs.writeText "options.schema.json" text;
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

          "packages.md" = let
            text = self.lib.docs.mkPackageDocs pkgs.flake;
          in {
            description = "Flake packages";
            source = pkgs.writeText "packages.md" text;
          };

          "flake-tree.dot" = {
            description = "Flake input tree. Converted to SVG when building HTML.";
            source = pkgs.runCommand "flake-tree.dot" {buildInputs = with pkgs; [flake.nix-utils graphviz];} ''
              # Ignore standard inputs to avoid cluttering the graph
              # Chosen mostly arbitrarily
              flake-tree --dot ${self}/flake.lock \
                nixpkgs systems flake-utils > $out
            '';
          };
        };
      };

      custom.shortcuts.palette.actions = lib.singleton {
        description = "View documentation";
        # These are built from markdown where the convention is `readme.md` rather than `index.html`
        action = ["xdg-open" "${cfg.build.combined}/readme.html"];
      };

      home.file."${config.custom.repoPath}/docs/generated" = {
        source = cfg.build.generated.md;
        recursive = true;
      };
    };
}
