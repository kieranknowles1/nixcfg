{
  mkShellNoCC,
  opentofu,
  awscli2,
  flake,
  python312,
}:
flake.lib.shell.mkShellEx mkShellNoCC {
  name = "meta";

  packages = [
    flake.rebuild
    
    # Requirements for IAC changes
    opentofu
    awscli2

    # Used by [[../modules/home/espanso/patch-matches.py]]
    (python312.withPackages (python-pkgs: [
      python-pkgs.pyyaml
    ]))
  ];

  shellHook = ''
    cd "$FLAKE"
  '';
}
