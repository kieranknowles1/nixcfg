{
  pkgs,
  flakeLib,
  flakePkgs,
}: {
  openmw = import ./openmw.nix {inherit pkgs flakeLib;};

  meta = import ./meta.nix {inherit pkgs flakeLib flakePkgs;};

  rust = import ./rust.nix {inherit pkgs flakeLib;};
}
