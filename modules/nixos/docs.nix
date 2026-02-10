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
    baseUrl = mkOption {
      type = types.str;
      defaultText = "config.custom.repoPath";
      example = "https://git.example.com/user/repo/blob/main";
      description = ''
        The base URL for links to option declarations.
      '';
    };
  };

  config = {
    # This isn't very useful due to its format, especially the options page
    # which struggles to render due to its size.
    documentation.nixos.enable = false;

    custom.docs-generate.baseUrl = lib.mkDefault config.custom.repoPath;

    # Default generated pages
    custom.docs-generate.file = let
      cfg = config.custom.docs-generate;
      inherit (self.builders.${pkgs.system}) mkOptionDocs mkFunctionDocs;
    in {
      "host-options.md" = {
        description = "NixOS options";
        source = mkOptionDocs {
          module = self.nixosModules.default;
          title = "NixOS options";
          inherit (cfg) baseUrl;
        };
      };
      "user-options.md" = {
        description = "Home Manager options";
        source = mkOptionDocs {
          module = self.homeModules.default;
          title = "Home Manager options";
          inherit (cfg) baseUrl;
        };
      };

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
