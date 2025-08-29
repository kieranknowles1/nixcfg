{
  lib,
  pkgs,
  self,
  config,
  ...
}: {
  options.custom = let
    inherit (lib) mkOption types;

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
    docs = {
      generateManCache = mkOption {
        description = ''
          Whether to generate man cache, required for carapace completions
          and `whatis`. Slow to build on some systems.
        '';
        default = true;
      };
    };

    docs-generate = {
      jsonIgnoredOptions = {
        nixos = mkIgnoredOptions "NixOS";
        home = mkIgnoredOptions "Home Manager";
      };
      baseUrl = mkOption {
        description = ''
          The base URL for links to option declarations.
        '';
        defaultText = "config.custom.repoPath";
        example = "https://git.example.com/user/repo/blob/main";
      };
    };
  };

  config = {
    documentation.man.generateCaches = config.custom.docs.generateManCache;

    # This isn't very useful due to its format, especially the options page
    # which struggles to render due to its size.
    documentation.nixos.enable = false;

    custom.docs-generate.baseUrl = lib.mkDefault config.custom.repoPath;

    # Default generated pages
    custom.docs-generate.file = let
      cfg = config.custom.docs-generate;
      inherit (self.builders.${pkgs.system}) mkOptionDocs mkFunctionDocs;
      mkSchema = name: module: hidden: let
        filterCustom = opts: opts.custom;
        filterNotHidden = opts: builtins.removeAttrs opts hidden;

        text = self.lib.docs.mkJsonSchema module (opts: filterNotHidden (filterCustom opts));
      in {
        description = "${name} options schema";
        source = pkgs.writeText "options.schema.json" text;
      };
    in {
      "host-options.md" = {
        description = "NixOS options";
        source = mkOptionDocs {
          module = self.nixosModules.default;
          title = "NixOS options";
          inherit (cfg) baseUrl;
        };
      };
      "host-options.schema.json" = mkSchema "NixOS" self.nixosModules.default cfg.jsonIgnoredOptions.nixos;
      "user-options.md" = {
        description = "Home Manager options";
        source = mkOptionDocs {
          module = self.homeManagerModules.default;
          title = "Home Manager options";
          inherit (cfg) baseUrl;
        };
      };
      "user-options.schema.json" = mkSchema "Home Manager" self.homeManagerModules.default cfg.jsonIgnoredOptions.home;

      # TODO: Also document builders
      "lib.md" = {
        description = "Nix Library";
        source = mkFunctionDocs ../../lib;
      };

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
}
