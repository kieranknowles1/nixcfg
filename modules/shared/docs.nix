{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.docs-generate = let
    inherit (lib) mkOption types;
  in {
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

      example = lib.literalExpression ''
        "file-a.md" = {
          description = "Some generated stuff";
          source = ./docs-generated/file-a.md;
          # Set to false if the file will be the same regardless of the host/user's
          # config
          dynamic = true;
        };
      '';

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
            example = lib.literalExpression "./docs-generated/file-a.md";
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

  config.warnings = lib.optional (builtins.compareVersions pkgs.mdbook.version "0.5.0" > 0) "mdbook 0.5.0 makes mdbook-admonish obsolete";

  config.custom.docs-generate.build = let
    cfg = config.custom.docs-generate;
    static = ../../docs;

    index = let
      value = name: cfg.file.${name};

      filtered = builtins.filter (lib.strings.hasSuffix ".md") (builtins.attrNames cfg.file);
      groups = builtins.groupBy (name:
        if (value name).dynamic
        then "dynamic"
        else "static")
      filtered;

      linkLine = name: "   - [${(value name).description}](./generated/${name})";
      mkLinks = items: builtins.concatStringsSep "\n" (map linkLine items);

      mkSection = header: key:
        lib.optionalString (builtins.hasAttr key groups) ''
          ${header}
          ${mkLinks groups.${key}}
        '';

      generated = ''
        ${mkSection "- [Global](./meta/generated-global.md)" "static"}
        ${mkSection "- [Machine-Specific](./meta/generated-dynamic.md)" "dynamic"}
      '';
    in
      pkgs.writeTextDir "SUMMARY.md" (builtins.readFile "${static}/SUMMARY.md" + generated);

    buildMd = name:
      pkgs.runCommand name {} ''
        mkdir -p $out/generated
        cp ${cfg.file.${name}.source} $out/generated/${name}
      '';
  in {
    # Step 1: Build generated docs (mostly markdown, but some JSON and graphviz)
    generated = pkgs.symlinkJoin {
      name = "generated-docs";
      paths = map buildMd (builtins.attrNames cfg.file);
    };

    # Step 2: Combine static and generated markdown. Not used directly but
    # convenient for later
    combined.markdown = pkgs.symlinkJoin {
      name = "combined-docs-md";
      # Index before static to override SUMMARY.md
      paths = [cfg.build.generated index static];
    };

    # Step 3: Build HTML from combined markdown
    # mdbook is fast, so don't worry about speed
    combined.html =
      pkgs.runCommand "combined-docs-html" {
        SRC = cfg.build.combined.markdown;

        buildInputs = with pkgs; [
          mdbook
          mdbook-admonish
          graphviz
          mdbook-graphviz
        ];
      } ''
        mkdir -p $out
        mdbook build --dest-dir $out $SRC
      '';
  };
}
