{
  pkgs,
}:
pkgs.flake.lib.shell.mkShellEx {
  name = "meta";

  packages = with pkgs; [
    flake.export-blueprints
    flake.factorio-blueprint-decoder
    flake.rebuild
    nil
  ];

  shellHook = ''
    cd "$FLAKE"
  '';
}
