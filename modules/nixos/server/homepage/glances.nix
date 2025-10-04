{
  config,
  lib,
  pkgs,
  ...
}: {
  # options.custom.server.glances = let
  #   inherit (lib) mkOption mkEnableOption types;
  # in {
  #   enable = mkEnableOption "Glances";
  # };

  config = let
    cfg = config.custom.server;
    cfgh = cfg.homepage;
  in lib.mkIf cfgh.enable {
    # No subdomain - this is only used internally by homepage
    # custom.server.subdomains.${cfgg.subdomain} = {
    #   proxyPort = cfg.ports.tcp.glances;
    # };

    services.glances = {
      enable = true;
      port = cfg.ports.tcp.glances;
      openFirewall = false;
    };
  };
}
