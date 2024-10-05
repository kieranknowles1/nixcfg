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
  options.custom.games.factorio = {
    blueprints = lib.mkOption {
      description = ''
        A directory containing Factorio blueprints, as exported using `export-blueprints`.
      '';
      type = lib.types.path;
      # TODO: Move this to its own repository, the files are quite large and add a download
      # when using the flake as a dependency.
      default = ./blueprints;
      defaultText = "./blueprints";
    };
  };

  # There's currently no way to create a blueprint binary directly, so we provide a string
  # that can be imported into Factorio.
  config = let
    cfg = config.custom.games.factorio;
  in
    lib.mkIf hostConfig.custom.games.enable {
      home.file."Games/configs/factorio-blueprints.txt".source = convert cfg.blueprints;
    };
}
