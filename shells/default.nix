{
  pkgs,
  flake,
  system,
}: let
  callPackage = pkgs.callPackage;
  flakePkgs = flake.packages.${system};
in {
  openmw = callPackage ./openmw.nix {inherit flake;};

  # `default.nix` is already used for this file, so use a different name
  default = callPackage ./defaultShell.nix {inherit flakePkgs flake;};

  rust = callPackage ./rust.nix {inherit flake;};
}
