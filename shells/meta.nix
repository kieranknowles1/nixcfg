{
  flakeLib,
  flakePkgs,
}:
flakeLib.shell.mkShellEx {
  name = "meta";

  packages = with flakePkgs; [
    export-blueprints
    factorio-blueprint-decoder
    rebuild
  ];

  shellHook = ''
    cd "$FLAKE"
  '';
}
