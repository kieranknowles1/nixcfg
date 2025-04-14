{
  pkgs,
  self,
  lib,
  config,
  ...
}: {
  options.custom.games.openmw = let
    mkStorageOption = name: example:
      lib.mkOption {
        description = ''
          The JSON file containing ${name} storage data,
          as exported using the OpenMW LuaData tool.
        '';
        type = lib.types.path;
        example = lib.options.literalExpression example;
      };
  in {
    luaData.package = lib.mkPackageOption pkgs.flake "openmw-luadata" {};

    globalStorage = mkStorageOption "global" "./global_storage.json";
    playerStorage = mkStorageOption "player" "./player_storage.json";
  };

  config = let
    cfg = config.custom.games.openmw;
    converter = lib.getExe cfg.luaData.package;

    # Encode a JSON file back to OpenMW's binary format
    # Runs at build time
    jsonToOmw = json:
      pkgs.runCommand "omw-lua.bin" {} ''
        ${converter} encode --input ${json} --output $out
      '';

    # Decode a binary file back to JSON format
    # Runs at runtime
    omwToJson = pkgs.writeShellScript "omw-json" ''
      exec ${converter} decode $@
    '';

    mkStorage = repo: {
      source = jsonToOmw "${self}/${repo}";
      repoPath = repo;
      transformer = omwToJson;
    };
  in
    lib.mkIf config.custom.games.enable {
      home = {
        packages = with pkgs; [
          openmw
        ];
      };

      custom.mutable.file = {
        # TODO: Use the options we have, need to specify repo paths in them
        ".config/openmw/global_storage.bin" = mkStorage "users/kieran/openmw/global_storage.json";
        ".config/openmw/player_storage.bin" = mkStorage "users/kieran/openmw/player_storage.json";
      };
    };
}
