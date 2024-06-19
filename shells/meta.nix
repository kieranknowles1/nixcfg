{
  pkgs,
  flakePkgs
}: pkgs.mkShellNoCC {
  packages = with flakePkgs; [
    export-blueprints
    factorio-blueprint-decoder
  ];

  # TODO: Add our own mkShell that sets the interpreter to nushell
  # We use exec to replace bash with nushell, rather than running nushell in bash which would require a second exit command
  shellHook = ''
    cd "$FLAKE"
    exec nu
  '';
}
