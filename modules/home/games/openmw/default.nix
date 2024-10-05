{
  pkgs,
  hostConfig,
  lib,
  config,
  ...
}: let
  cfg = config.custom.games.openmw;

  # Encode a JSON file back to OpenMW's binary format
  toOmwData = json: let
    converter = lib.getExe cfg.luaData.package;
  in
    pkgs.runCommand "omw-lua.bin" {} ''
      ${converter} encode --input ${json} --output $out
    '';
in {
  # TODO: Store data with the user, as in Factorio
  options.custom.games.openmw = let
    mkStorageOption = name: default: defaultText: lib.mkOption {
      description = ''
        The JSON file containing ${name} storage data,
        as exported using the OpenMW LuaData tool.
      '';
      type = lib.types.path;
      inherit default defaultText;
    };
  in {
    luaData.package = lib.mkPackageOption pkgs.flake "openmw-luadata" {};

    globalStorage = mkStorageOption "global" ./global_storage.json "./global_storage.json";
    playerStorage = mkStorageOption "player" ./player_storage.json "./player_storage.json";
  };

  config = let
    cfg = config.custom.games.openmw;
  in lib.mkIf hostConfig.custom.games.enable {
    home = {
      packages = with pkgs; [
        flake.openmw-dev
      ];

      # TODO: Use an impure provisioner to install Lua data files directly to ~/.config/openmw
      # TODO: Consider syncing rest my openmw config
      file = {
        "Games/configs/openmw/global_storage.dat".source = toOmwData cfg.globalStorage;
        "Games/configs/openmw/player_storage.dat".source = toOmwData cfg.playerStorage;
      };
    };
  };
}
