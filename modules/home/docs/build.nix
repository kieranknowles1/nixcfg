{
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  config.custom.docs-generate.build = let
    cfg = config.custom.docs-generate;
    static = ../../../docs;

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

      generated = ''
        - [Global](./meta/generated-global.md)
        ${mkLinks groups.static}
        - [Machine-Specific](./meta/generated-dynamic.md)
        ${mkLinks groups.dynamic}
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
    # buildStaticSite does some pre-processing which converts graphs to SVG
    combined.markdown = self.builders.${pkgs.system}.buildStaticSite {
      name = "combined-docs-md";
      src = pkgs.symlinkJoin {
        name = "combined-docs-md";
        # Index before static to override SUMMARY.md
        paths = [cfg.build.generated index static];
      };
    };

    # Step 3: Build HTML from combined markdown
    # mdbook is fast, so don't worry about speed
    combined.html =
      pkgs.runCommand "combined-docs-html" {
        SRC = cfg.build.combined.markdown;

        buildInputs = with pkgs; [
          mdbook
          mdbook-admonish
        ];
      } ''
        mkdir -p $out
        mdbook build --dest-dir $out $SRC
      '';
  };
}
