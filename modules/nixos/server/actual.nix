{
  config,
  lib,
  ...
}: {
  options.custom.server.actual = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "Actual Finance";

    subdomain = mkOption {
      type = types.string;
      default = "finance";
      description = "The subdomain for Actual";
    };
  };

  config = let
    cfg = config.custom.server;
    cfga = cfg.actual;
  in
    lib.mkIf cfga.enable {
      custom.server.subdomains = {
        ${cfga.subdomain}.proxyPort = cfg.ports.tcp.actual;
      };

      services.actual = {
        enable = true;
        settings = {
          port = cfg.ports.tcp.actual;
        };
      };
    };
}
