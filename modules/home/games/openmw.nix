{
  pkgs,
  lib,
  config,
  ...
}: {
  options.custom.games.openmw = let
    mkStorageSubOption = name: example: typeDesc: type:
      lib.mkOption {
        inherit type;
        description = ''
          ${typeDesc} path to a JSON file containing ${name}
          storage data, as exported using the OpenMW LuaData tool.
        '';
        example = lib.options.literalExpression example;
      };

    mkStorageOptions = name: example: {
      nix = mkStorageSubOption name "$./${example}" "Nix" lib.types.path;
      repo = mkStorageSubOption name "user/${example}" "Repository relative" lib.types.str;
    };
  in {
    luaData.package = lib.mkPackageOption pkgs.flake "openmw-luadata" {};

    globalStorage = mkStorageOptions "global" "global_storage.json";
    playerStorage = mkStorageOptions "player" "player_storage.json";
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

    mkStorage = opts: {
      source = jsonToOmw opts.nix;
      repoPath = opts.repo;
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
        ".config/openmw/global_storage.bin" = mkStorage cfg.globalStorage;
        ".config/openmw/player_storage.bin" = mkStorage cfg.playerStorage;
      };
    };
}
