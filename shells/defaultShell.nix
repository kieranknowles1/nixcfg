{
  lib,
  writeShellScriptBin,
  mkShellNoCC,
  nil,
  flake,
  python312,
}:
let
  openmw-luadata = lib.getExe flake.openmw-luadata;

  export-openmw = writeShellScriptBin "export-openmw" ''
    config_dir="$HOME/.config/openmw"

    ${openmw-luadata} decode "$config_dir/global_storage.bin" > "$FLAKE/users/kieran/openmw/global_storage.json"
    ${openmw-luadata} decode "$config_dir/player_storage.bin" > "$FLAKE/users/kieran/openmw/player_storage.json"
  '';
in
flake.lib.shell.mkShellEx mkShellNoCC {
  name = "meta";

  packages = [
    flake.export-blueprints
    flake.factorio-blueprint-decoder
    flake.rebuild
    nil
    export-openmw

    # Used by [[../modules/home/espanso/patch-matches.py]]
    (python312.withPackages (python-pkgs: [
      python-pkgs.pyyaml
    ]))
  ];

  shellHook = ''
    cd "$FLAKE"
  '';
}
