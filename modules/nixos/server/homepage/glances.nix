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

    _mkMetric = chart: name: metric: {
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
          inherit chart metric;
        };
      };
    };
    mkMetric = _mkMetric true;
    # Don't display a chart for disk usage, a 5 minute period is
    # useless there
    mkDiskMetric = _mkMetric false;
  in lib.mkIf cfgh.enable {
    # No subdomain - this is only used internally by homepage
    # custom.server.subdomains.${cfgg.subdomain} = {
    #   proxyPort = cfg.ports.tcp.glances;
    # };

    custom.server.homepage.services = [
      (mkMetric "About" "info")
      (mkMetric "CPU Usage" "cpu")
      (mkMetric "Memory Usage" "memory")
      (mkMetric "Network I/O" "network:end0")
      (mkMetric "CPU Temperature" "sensor:cpu_thermal 0")
      (mkMetric "Disk I/O" "disk:sda1")
      (mkDiskMetric "SD Card" "fs:/")
      (mkDiskMetric "Primary HDD" "fs:/mnt/extern")
    ];

    services.glances = let
      # HACK: Glances doesn't let us selectively enable plugins, so we have to
      # brute force it a bit
      # It seems
      allPlugins = [
        "sensors"
        "system"
        "programlist"
        "ports"
        "uptime"
        "core"
        "vms"
        "processlist"
        "percpu"
        "fs"
        "version"
        "amps"
        "ip"
        "mem"
        "cpu"
        "wifi"
        "load"
        "network"
        "containers"
        "memswap"
        "folders"
        "cloud"
        "help"
        "diskio"
        "gpu"
        "quicklook"
        "psutilversion"
        "raid"
        "now"
        "irq"
        "connections"
        "alert"
        "processcount"
      ];
      usedPlugins = [
        # Self explanatory
        "cpu"
        "mem"
        "uptime"
        "diskio"
        "network"

        # Average waiting processes
        # We don't display this, but annoyingly homepage requires the endpoint
        # to be active
        "load"

        # Temperature
        "sensors"
        # Disk usage
        "fs"

        # OS info
        "quicklook"
        "system"
      ];

      disablePlugins = lib.lists.subtractLists usedPlugins allPlugins;
    in {
      enable = true;
      port = cfg.ports.tcp.glances;
      openFirewall = false;

      extraArgs = [
        "--webserver"
        "--disable-webui"

        "--disable-plugin" (builtins.concatStringsSep "," disablePlugins)
      ];
    };
  };
}
