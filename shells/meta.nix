{
  flakeLib,
  flakePkgs
}: flakeLib.shell.mkShellEx {
  packages = with flakePkgs; [
    export-blueprints
    factorio-blueprint-decoder
    rebuild
  ];

  shellHook = ''
    cd "$FLAKE"
  '';
}
