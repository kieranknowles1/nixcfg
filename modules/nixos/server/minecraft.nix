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
  };

  config = let
    cfg = config.custom.server;
    cfgm = cfg.minecraft;
  in lib.mkIf cfgm.enable {
    custom.server.minecraft.dataDir = lib.mkDefault "${cfg.data.baseDirectory}/minecraft";

    services.minecraft-server = {
      inherit (cfgm) whitelist;
      enable = true;
      eula = true;
      openFirewall = true;

      declarative = true;
    };
  };
}
