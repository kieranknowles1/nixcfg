{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.server.trilium = let
    inherit (lib) mkOption mkEnableOption mkPackageOption types;
  in {
    enable = mkEnableOption "Trilium server";

    subdomain = mkOption {
      type = types.str;
      description = "Subdomain for Trilium server";
      default = "notes";
    };

    dataDir = mkOption {
      type = types.path;
      description = "Path to the Trilium data directory";
    };

    package = mkPackageOption pkgs "trilium-next-server" {};
  };

  config = let
    cfg = config.custom.server;
    cfgt = cfg.trilium;
  in
    lib.mkIf cfgt.enable {
      custom.server = {
        trilium.dataDir = lib.mkDefault "${cfg.baseDataDir}/trilium";
        subdomains.${cfgt.subdomain} = {
          proxyPort = cfg.ports.tcp.trilium;
          webSockets = true;
        };
      };

      services.trilium-server = {
        enable = true;
        port = cfg.ports.tcp.trilium;
        inherit (cfgt) dataDir package;

        nginx.enable = false; # We handle this ourselves
      };
    };
}
