{
  pkgs,
  lib,
  config,
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
      type = types.path;

      example = options.literalExpression "./blueprints";
    };

    blueprints-repo = mkOption {
      description = ''
        A repository to extract new blueprints into.
      '';
      type = types.str;
      example = "/home/bob/factorio-blueprints";
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

    exportScript = pkgs.writeShellScript "export-blueprints" ''
      cd ${cfg.blueprints-repo}
      nix run .
      git add .
      git commit -m "Update blueprints on $(date)"
      git push
    '';
  in
    lib.mkIf config.custom.games.enable {
      home.file."Games/configs/factorio-blueprints.txt" = lib.mkIf (cfg.blueprints != null) {
        source = convert cfg.blueprints;
      };

      custom.mutable.file.".factorio/config/config.ini" = lib.mkIf (cfg.configFile != null) {
        inherit (cfg.configFile) repoPath;
        source = cfg.configFile.file;
      };

      custom.shortcuts.palette.actions = lib.singleton {
        action = [exportScript];
        description = "Export Factorio blueprints";
        useTerminal = true;
      };
    };
}
