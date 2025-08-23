{
  config,
  lib,
  ...
}: {
  options.custom.server.homepage = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "gethomepage";
    subdomain = mkOption {
      type = types.str;
      default = "home";
      description = "The subdomain for gethomepage";
    };
  };

  config = let
    cfg = config.custom.server;
    cfgh = cfg.homepage;
  in
    lib.mkIf cfgh.enable {
      custom.server.subdomains.${cfgh.subdomain} = {
        proxyPort = config.services.homepage-dashboard.listenPort;
      };

      services.homepage-dashboard = {
        enable = true;
        listenPort = cfg.ports.tcp.homepage;
        allowedHosts = cfg.hostname;
      };
    };
}
