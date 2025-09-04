{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.server.minecraft = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "Minecraft";

    dataDir = mkOption {
      type = types.path;
      defaultText = "$${config.custom.server.data.baseDirectory}/minecraft";
      description = "The directory where Minecraft server data will be stored.";
    };

    whitelist = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = ''
        Whitelisted players in the form `username = uuid`.
        See [https://mcuuid.net/](https://mcuuid.net/).
      '';
    };

    # TODO: Remove this once https://github.com/Infinidoge/nix-minecraft/pull/145 is resolved
    # Will be obsolete with start/stop being automated
    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to automatically start the Minecraft server.

        Requires ~2GB of RAM, so disabled by default.
      '';
    };

    version = mkOption {
      type = types.str;
      default = "1.21.8";
      description = "The version of Minecraft server to use.";
    };
    packWizHash = mkOption {
      type = types.str;
      default = "sha256-Xej4hlWLOOXl6YciJ0q/kNet4KFXLiQmfIuZGwCjFhg=";
      example = "sha256-...";
      description = "The hash of the Fabulously Optimized modpack.";
    };
  };

  config = let
    cfg = config.custom.server;
    cfgm = cfg.minecraft;
  in lib.mkIf cfgm.enable {
    custom.server.minecraft.dataDir = lib.mkDefault "${cfg.data.baseDirectory}/minecraft";

    # Command to start server if it isn't already running, and connects to its console
    # To exit, use `Ctrl+b, d`
    # TODO: Remove once https://github.com/Infinidoge/nix-minecraft/issues/166 is resolved
    # Will be obsolete with CLI
    environment.systemPackages = lib.singleton (pkgs.writeShellScriptBin "mine-up" ''
      SERVERNAME=default
      SERVICE=minecraft-server-$SERVERNAME.service

      if ! systemctl is-active $SERVICE; then
        sudo systemctl start $SERVICE
      fi
      sudo -u minecraft ${lib.getExe pkgs.tmux} -S /run/minecraft/$SERVERNAME.sock attach
    '');

    services.minecraft-servers = {
      inherit (cfgm) dataDir;
      enable = true;
      eula = true;
      openFirewall = true;

      servers.default = {
        enable = true;
        inherit (cfgm) whitelist autoStart;
        # "Always" interferes with /stop
        restart = "no";

        package = pkgs.fabricServers."fabric-${builtins.replaceStrings ["."] ["_"] cfgm.version}";

        serverProperties = {
          port = cfg.ports.tcp.minecraft;
        };

        symlinks = let
          modpack = pkgs.fetchPackwizModpack {
            url = "https://raw.githubusercontent.com/Fabulously-Optimized/fabulously-optimized/refs/heads/main/Packwiz/${cfgm.version}/pack.toml";
            packHash = cfgm.packWizHash;
          };
        in {
          mods = "${modpack}/mods";
        };
      };
    };
  };
}
