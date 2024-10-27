{
  pkgs,
  lib,
  config,
  hostConfig,
  ...
}: let
  combine-blueprints = lib.getExe pkgs.flake.combine-blueprints;

  convert = directory:
    pkgs.runCommand "blueprints.txt" {} ''
      ${combine-blueprints} ${directory} > $out
    '';
in {
  options.custom.games.factorio = let
    inherit (lib) mkOption types options;
  in {
    blueprints = mkOption {
      description = ''
        A directory containing Factorio blueprints, as exported using `export-blueprints`.
      '';
      type = types.nullOr types.path;

      example = options.literalExpression "./blueprints";
    };

    configFile = {
      file = mkOption {
        description = ''
          The Factorio configuration file.
        '';
        type = types.nullOr types.path;
        default = null;
        example = options.literalExpression "./factorio.ini";
      };

      repoPath = mkOption {
        description = ''
          The position of the config file relative to the repository root.
        '';
        type = types.str;
        example = "users/bob/factorio.ini";
      };
    };
  };

  # There's currently no way to create a blueprint binary directly, so we provide a string
  # that can be imported into Factorio.
  config = let
    cfg = config.custom.games.factorio;
  in
    lib.mkIf hostConfig.custom.games.enable {
      home.file."Games/configs/factorio-blueprints.txt" = lib.mkIf (cfg.blueprints != null) {
        source = convert cfg.blueprints;
      };

      custom.mutable.file.".factorio/config/config.ini" = lib.mkIf (cfg.configFile != null) {
        inherit (cfg.configFile) repoPath;
        source = cfg.configFile.file;
      };
    };
}
