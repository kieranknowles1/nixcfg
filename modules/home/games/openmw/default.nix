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
    pkgs.runCommand "omw-lua-convert" {} ''
      ${converter} encode --input ${json} --output $out
    '';
in {
  options.custom.games.openmw = {
    luaData.package = lib.mkPackageOption pkgs.flake "openmw-luadata" {};
  };

  config = lib.mkIf hostConfig.custom.games.enable {
    home = {
      packages = with pkgs; [
        flake.openmw-dev
      ];

      # TODO: Use an impure provisioner to install Lua data files directly to ~/.config/openmw
      # TODO: Consider syncing rest my openmw config
      file = {
        "Games/configs/openmw/global_storage.dat".source = toOmwData ./global_storage.json;
        "Games/configs/openmw/player_storage.dat".source = toOmwData ./player_storage.json;
      };
    };
  };
}
