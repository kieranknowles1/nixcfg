{
  pkgs,
  flakeLib,
  flakePkgs,
}: {
  openmw = import ./openmw.nix {inherit pkgs flakeLib;};

  # `default.nix` is already used for this file, so use a different name
  default = import ./defaultShell.nix {inherit pkgs flakePkgs flakeLib;};

  rust = import ./rust.nix {inherit pkgs flakeLib;};
}
