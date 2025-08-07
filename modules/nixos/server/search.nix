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
    mkModuleOption = name:
      mkOption {
        type = types.anything;

        description = "${name} options to generate search for. Defaults to the nixcfg flake's default module.";
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

    nixosModules = mkModuleOption "NixOS";
    homeModules = mkModuleOption "Home Manager";

    githubUrl = mkOption {
      type = types.str;
      default = "https://github.com/kieranknowles1/nixcfg/";
      description = ''
        The base URL of the configuration's GitHub repository.
      '';
    };
  };

  config = let
    inherit (inputs.nuschtosSearch.packages.${pkgs.system}) mkMultiSearch;

    cfg = config.custom.server;
    cfgs = cfg.search;
  in
    lib.mkIf cfgs.enable {
      custom.server.search = {
        nixosModules = self.nixosModules.default;
        homeModules = self.homeManagerModules.default;
      };

      custom.server.subdomains = {
        ${cfgs.subdomain} = {
          cache.enable = true;
          root = mkMultiSearch {
            baseHref = "/";
            scopes = [
              {
                name = "NixOS Modules";
                modules = [cfgs.nixosModules];
                urlPrefix = cfgs.githubUrl;
              }
              {
                name = "Home Manager Modules";
                modules = [cfgs.homeModules];
                urlPrefix = cfgs.githubUrl;
              }
            ];
          };
        };
      };
    };
}
