{
  config,
  lib,
  ...
}: {
  options.custom.server.jellyfin = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "Jellyfin";

    subdomain = mkOption {
      type = types.str;
      default = "film";
      description = "The subdomain for Jellyfin.";
    };

    dataDir = mkOption {
      type = types.path;
      defaultText = "$${config.custom.server.data.baseDirectory}/jellyfin";
      description = "The directory where Jellyfin will store its (non media) data.";
    };
  };

  config = let
    cfg = config.custom.server;
    cfgj = cfg.jellyfin;
  in
    lib.mkIf cfg.enable {
      custom.server = {
        jellyfin.dataDir = lib.mkDefault "${cfg.data.baseDirectory}/jellyfin";
        subdomains.${cfgj.subdomain} = {
          proxyPort = cfg.ports.jellyfin-http;
        };
      };
      services.jellyfin = {
        enable = true;
        inherit (cfgj) dataDir;
      };
    };
}
