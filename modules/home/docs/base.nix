# Default generated documentation pages
{
  self,
  pkgs,
  config,
  ...
}: {
  config.custom.docs-generate.file = let
    cfg = config.custom.docs-generate;
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
        flake-tree --dot ${../../../flake.lock} nixpkgs systems flake-utils | \
          ${pkgs.graphviz}/bin/dot -Tsvg -o $out
      '';
    };
  };
}
