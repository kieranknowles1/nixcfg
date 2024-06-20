{
  flakeLib,
  flakePkgs
}: flakeLib.shell.mkShellEx {
  packages = with flakePkgs; [
    export-blueprints
    factorio-blueprint-decoder
    rebuild
  ];

  # TODO: Add our own mkShell that sets the interpreter to nushell
  # We use exec to replace bash with nushell, rather than running nushell in bash which would require a second exit command
  # Shells are impure and inherit environment variables. This lets us use them in hooks.
  shellHook = ''
    export DEVSHELL=1
    cd "$FLAKE"
    exec "$SHELL"
  '';
}
