{
  pkgs,
  flake,
  system,
}: let
  callPackage = pkgs.callPackage;
in {
  openmw = callPackage ./openmw.nix {inherit flake;};

  # `default.nix` is already used for this file, so use a different name
  default = callPackage ./defaultShell.nix {inherit flake;};

  rust = callPackage ./rust.nix {inherit flake;};
}
