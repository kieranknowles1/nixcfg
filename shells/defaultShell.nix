{
  flake,
  flakePkgs,
  pkgs,
}:
flake.lib.shell.mkShellEx {
  name = "meta";

  packages = with pkgs; [
    flakePkgs.export-blueprints
    flakePkgs.factorio-blueprint-decoder
    flakePkgs.rebuild
    nil
  ];

  shellHook = ''
    cd "$FLAKE"
  '';
}
