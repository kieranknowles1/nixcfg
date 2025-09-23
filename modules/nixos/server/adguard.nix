{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.server.adguard = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "AdGuard Home";
    subdomain = mkOption {
      type = types.str;
      default = "dns";
      description = "The subdomain to use for AdGuard Home";
    };
  };

  config = let
    cfg = config.custom.server;
    cfga = cfg.adguard;
  in lib.mkIf cfga.enable {
    custom.server = {
      subdomains.${cfga.subdomain}.proxyPort = config.services.adguardhome.port;
    };

    services.adguardhome = {
      enable = true;
      port = cfg.ports.tcp.adguard;
    };

    networking.firewall.allowedTCPPorts = [ cfg.ports.tcp.dns ];
  };
}
