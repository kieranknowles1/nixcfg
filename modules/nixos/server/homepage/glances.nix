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

    mkMetric = name: metric: {
      inherit name;
      group = "Metrics";
      href = null;
      description = null;
      icon = null;
      widget = {
        type = "glances";
        config = {
          url = "http://localhost:${builtins.toString cfg.ports.tcp.glances}";
          version = 4;
          inherit metric;
        };
      };
    };
  in lib.mkIf cfgh.enable {
    # No subdomain - this is only used internally by homepage
    # custom.server.subdomains.${cfgg.subdomain} = {
    #   proxyPort = cfg.ports.tcp.glances;
    # };

    custom.server.homepage.services = [
      (mkMetric "CPU Usage" "cpu")
      (mkMetric "Memory Usage" "memory")
      (mkMetric "Network Usage" "network:end0")
      (mkMetric "Top Processes" "process")
      (mkMetric "CPU Temperature" "sensor:cpu_thermal 0")
      (mkMetric "Disk I/O" "disk:sda1")
    ];

    services.glances = {
      enable = true;
      port = cfg.ports.tcp.glances;
      openFirewall = false;

      # FIXME: glances has an unreasonably high CPU usage
      extraArgs = [
        "--webserver"
        "--disable-webui"
      ];
    };
  };
}
