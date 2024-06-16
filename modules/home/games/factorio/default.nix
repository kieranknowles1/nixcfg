{
  pkgs,
  lib,
  config,
  flake,
  hostConfig,
  ...
}: let
  combine-blueprints = "${flake.packages.x86_64-linux.combine-blueprints}/bin/combine-blueprints";

  blueprintString = let
    result = pkgs.runCommand "blueprintString" {} ''
      mkdir -p $out
      ${combine-blueprints} ${./blueprints} > $out/blueprints.txt
    '';
  in "${result}/blueprints.txt";
in {
  # There's currently no way to create a blueprint binary directly, so we provide a string
  # that can be imported into Factorio.
  config = lib.mkIf hostConfig.custom.games.enable {
    home.file."Games/factorio-blueprints.txt".source = blueprintString;
  };
}
