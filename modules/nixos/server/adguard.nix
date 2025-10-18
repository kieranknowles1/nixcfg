{
  config,
  lib,
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
  in
    lib.mkIf cfga.enable {
      custom.server = {
        subdomains.${cfga.subdomain}.proxyPort = config.services.adguardhome.port;

        homepage.services = lib.singleton {
          group = "Infrastructure";
          name = "AdGuard Home";
          description = "Network-wide adblock";
          icon = "adguard-home.svg";
          href = "https://${cfga.subdomain}.${cfg.hostname}";
          widget = {
            type = "adguard";
            config = {
              url = "http://${cfga.subdomain}.${config.networking.hostName}.local";
              username = "homepage";
            };
            secrets.password = {
              id = "ADGUARD_PASSWORD";
              value = "adguard/homepage-password";
            };
          };
        };
      };

      services.adguardhome = {
        enable = true;
        port = cfg.ports.tcp.adguard;

        settings = {
          # Support Avahi-like .local extensions with subdomains
          filtering.rewrites = let
            hostname = config.networking.hostName;
            ip = config.custom.networking.fixedIp;
          in [
            {
              domain = "*.${hostname}.local";
              answer = ip;
            }
            {
              domain = "${hostname}.local";
              answer = ip;
            }
          ];
        };
      };

      # Most DNS requests go through UDP, but larger ones need TCP
      networking.firewall.allowedTCPPorts = [cfg.ports.tcp.dns];
      networking.firewall.allowedUDPPorts = [cfg.ports.udp.dns];
    };
}
