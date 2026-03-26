{
  config,
  lib,
  ...
}: {
  options.custom.server.immich.remote-ml = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "Immich remote machine learning";
  };

  config = let
    cfg = config.custom.server;
    cfgi = cfg.immich;
    cfgm = cfgi.remote-ml;

    inherit (lib) mkIf;

    commonServiceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 3;

      # Hardening
      CapabilityBoundingSet = "";
      NoNewPrivileges = true;
      PrivateUsers = true;
      PrivateTmp = true;
      PrivateDevices = true;
      # NOTE: Nixpkgs doesn't currently include CUDA builds of immich-machine-learning
      # Enabling hardware acceleration would require whitelisting devices
      DeviceAllow = [];
      PrivateMounts = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      UMask = "0077";
    };

    port = cfg.ports.tcp.immich-machine-learning;
  in
    mkIf cfgm.enable {
      # TODO: Nixpkgs doesn't allow enabling machine-learning separatly,
      # so copy-paste it's systemd unit config
      users.users.immich = {
        group = "immich";
        isSystemUser = true;
      };
      users.groups.immich = {};

      systemd.services.immich-machine-learning = {
        description = "immich machine learning";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        environment = {
          MACHINE_LEARNING_WORKERS = "1";
          MACHINE_LEARNING_WORKER_TIMEOUT = "120";
          MACHINE_LEARNING_CACHE_FOLDER = "/var/cache/immich";
          XDG_CACHE_HOME = "/var/cache/immich";
          # Listen on all incoming connections with the requested port
          IMMICH_HOST = "0.0.0.0";
          IMMICH_PORT = toString port;
        };
        serviceConfig =
          commonServiceConfig
          // {
            ExecStart = lib.getExe config.services.immich.package.machine-learning;
            Slice = "system-immich.slice";
            CacheDirectory = "immich";
            User = "immich";
            Group = "immich";
          };
      };

      networking.firewall.allowedTCPPorts = [port];
    };
}
