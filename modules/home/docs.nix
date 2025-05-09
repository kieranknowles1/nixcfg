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

  config = let
    cfg = config.custom.docs-generate;
  in
    lib.mkIf cfg.enable {
      custom.docs-generate = {
        # Step 1: Build generated docs (mostly markdown, but some JSON and graphviz)
        build = {
          generated = let
            buildMd = name:
              pkgs.runCommand name {} ''
                mkdir -p $out/generated
                cp ${cfg.file.${name}.source} $out/generated/${name}
              '';
          in
            pkgs.symlinkJoin {
              name = "generated-docs";
              paths = map buildMd (builtins.attrNames cfg.file);
            };

          # Step 2: Combine static and generated markdown. Not used directly but
          # convenient for later
          # buildStaticSite does some pre-processing which converts graphs to SVG
          combined.markdown = self.builders.${pkgs.system}.buildStaticSite {
            name = "combined-docs-md";
            src = pkgs.symlinkJoin {
              name = "combined-docs-md";
              paths = [cfg.build.generated ../../docs];
            };
          };

          # Step 3: Build HTML from combined markdown
          # mdbook is fast, so don't worry about speed
          combined.html =
            pkgs.runCommand "combined-docs-html" {
              SRC = cfg.build.combined.markdown;
              INDEX = let
                value = name: cfg.file.${name};

                filtered = builtins.filter (lib.strings.hasSuffix ".md") (builtins.attrNames cfg.file);
                groups = builtins.groupBy (name:
                  if (value name).dynamic
                  then "dynamic"
                  else "static")
                filtered;

                linkLine = name: "   - [${(value name).description}](./generated/${name})";
                mkLinks = items: builtins.concatStringsSep "\n" (map linkLine items);
              in ''
                - [Global](./meta/generated-global.md)
                ${mkLinks groups.static}
                - [Machine-Specific](./meta/generated-dynamic.md)
                ${mkLinks groups.dynamic}
              '';
              # builtins.concatStringsSep "\n"
              # (map linkLine
              #   (builtins.filter (lib.strings.hasSuffix ".md") (builtins.attrNames cfg.file)));
            } ''
              mkdir -p $out
              # Build from a temporary directory so we can inject the generated index
              tmpdir=$(mktemp --directory)
              cp -r $SRC/* $tmpdir/

              # Do some musical chairs to append the generated index to SUMMARY.md
              cp --remove-destination --dereference $SRC/SUMMARY.md $tmpdir/SUMMARY.md
              chmod +w $tmpdir/SUMMARY.md
              echo "$INDEX" >> "$tmpdir/SUMMARY.md"

              # Now we can build HTML
              ${lib.getExe pkgs.mdbook} build --dest-dir $out $tmpdir
            '';
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
            source = mkOptionDocs {
              module = self.nixosModules.default;
              title = "NixOS options";
              repoPath = config.custom.fullRepoPath;
            };
          };
          "host-options.schema.json" = mkSchema "NixOS" self.nixosModules.default cfg.jsonIgnoredOptions.nixos;
          "user-options.md" = {
            description = "Home Manager options";
            source = mkOptionDocs {
              module = self.homeManagerModules.default;
              title = "Home Manager options";
              repoPath = config.custom.fullRepoPath;
            };
          };
          "user-options.schema.json" = mkSchema "Home Manager" self.homeManagerModules.default cfg.jsonIgnoredOptions.home;

          "packages.md" = let
            text = self.lib.docs.mkPackageDocs pkgs.flake;
          in {
            description = "Flake packages";
            source = pkgs.writeText "packages.md" text;
          };

          "flake-tree.svg" = {
            description = "Flake input tree.";
            source = pkgs.runCommand "flake-tree.svg" {buildInputs = with pkgs; [flake.nix-utils graphviz];} ''
              # Ignore standard inputs to avoid cluttering the graph
              # Chosen mostly arbitrarily
              flake-tree --dot ${../../flake.lock} nixpkgs systems flake-utils | \
                ${pkgs.graphviz}/bin/dot -Tsvg -o $out
            '';
          };
        };
      };

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
