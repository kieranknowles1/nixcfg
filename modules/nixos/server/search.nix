{
  lib,
  config,
  self,
  inputs,
  pkgs,
  ...
}: {
  options.custom.server.search = let
    inherit (lib) mkOption mkEnableOption types;

    scopeType = types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          description = "Name of the scope shown in the description of options and scope filter dropdown";
          example = "My Glorious Modules";
        };
        modules = mkOption {
          type = types.listOf types.anything;
          description = "List of modules to generate search for";
        };
        urlPrefix = mkOption {
          type = types.str;
          description = "Link to the module's Git repository";
          example = "https://git.example.com/nixos";
        };
      };
    };
  in {
    enable = mkEnableOption "Options Search";

    subdomain = mkOption {
      type = types.str;
      default = "search";
      description = ''
        The subdomain to use for options search.
      '';
    };

    scopes = mkOption {
      type = types.listOf scopeType;
      default = [];
      description = ''
        List of scopes to generate search for.
      '';
    };
  };

  config.custom.server = let
    inherit (inputs.nuschtosSearch.packages.${pkgs.system}) mkMultiSearch;
    ghUrl = "https://github.com/kieranknowles1/nixcfg/";

    cfg = config.custom.server;
    cfgs = cfg.search;
  in
    lib.mkIf cfgs.enable {
      search.scopes = [
        {
          name = "NixOS Modules";
          modules = builtins.attrValues self.nixosModules;
          urlPrefix = ghUrl;
        }
        {
          name = "Home Manager Modules";
          modules = builtins.attrValues self.homeManagerModules;
          urlPrefix = ghUrl;
        }
        # TODO: Handle Stylix. This fails to import due to a missing `pkgs` attribute
        # and will need separate "home" and "nixos" scopes.
        # {
        #   name = "Stylix";
        #   modules = (builtins.attrValues inputs.stylix.nixosModules) ++ (builtins.attrValues inputs.stylix.homeManagerModules);
        #   urlPrefix = "https://github.com/nix-community/stylix";
        # }
        {
          name = "SOPS";
          # Home and NixOS options are functionally identical, so only show one.
          modules = builtins.attrValues inputs.sops-nix.nixosModules;
          urlPrefix = "https://github.com/Mic92/sops-nix";
        }
        {
          name = "Minecraft";
          modules = builtins.attrValues inputs.nix-minecraft.nixosModules;
          urlPrefix = "https://github.com/Infinidoge/nix-minecraft";
        }
        # FIXME: Same issue as stylix
        # {
        #   name = "Copyparty";
        #   modules = builtins.attrValues inputs.copyparty.nixosModules;
        #   urlPrefix = "https://github.com/9001/copyparty";
        # }
      ];

      subdomains = {
        ${cfgs.subdomain} = {
          cache.enable = true;
          root = mkMultiSearch {
            inherit (cfgs) scopes;
            baseHref = "/";
            title = "NüschtOS Search - NixOS Search, but German";
          };
        };
      };

      homepage.services = lib.singleton {
        group = "Meta";
        name = "Search";
        description = "Nix options search";
        icon = "nixos.svg";
        href = "https://${cfgs.subdomain}.${cfg.hostname}";
      };
    };
}
