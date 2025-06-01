{
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  config.custom.docs-generate.build = let
    cfg = config.custom.docs-generate;

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
    # buildStaticSite does some pre-processing which converts graphs to SVG
    combined.markdown = self.builders.${pkgs.system}.buildStaticSite {
      name = "combined-docs-md";
      src = pkgs.symlinkJoin {
        name = "combined-docs-md";
        paths = [cfg.build.generated ../../../docs];
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
}
