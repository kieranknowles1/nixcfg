{
  lib,
  pkgs,
  self,
  config,
  ...
}: {
  options.custom.docs-generate = let
    inherit (lib) mkOption types;
  in {
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
  };

  config = {
    documentation.man.generateCaches = true;

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
          # TODO: Point this an NixOS to GitHub, they aren't available on a server
          inherit (config.custom) repoPath;
        };
      };
      "host-options.schema.json" = mkSchema "NixOS" self.nixosModules.default cfg.jsonIgnoredOptions.nixos;
      "user-options.md" = {
        description = "Home Manager options";
        source = mkOptionDocs {
          module = self.homeManagerModules.default;
          title = "Home Manager options";
          inherit (config.custom) repoPath;
        };
      };
      "user-options.schema.json" = mkSchema "Home Manager" self.homeManagerModules.default cfg.jsonIgnoredOptions.home;

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
