{
  pkgs,
  lib,
  flake,
}: let
  openmw-luadata = lib.getExe flake.openmw-luadata;

  export-openmw = pkgs.writeShellScriptBin "export-openmw" ''
    config_dir="$HOME/.config/openmw"

    ${openmw-luadata} decode "$config_dir/global_storage.bin" > "$FLAKE/modules/home/games/openmw/global_storage.json"
    ${openmw-luadata} decode "$config_dir/player_storage.bin" > "$FLAKE/modules/home/games/openmw/player_storage.json"
  '';
in
  pkgs.flake.lib.shell.mkShellEx {
    name = "meta";

    packages = with pkgs; [
      flake.export-blueprints
      flake.factorio-blueprint-decoder
      flake.rebuild
      nil
      export-openmw
    ];

    shellHook = ''
      cd "$FLAKE"
    '';
  }
