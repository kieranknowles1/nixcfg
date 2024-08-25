{pkgs}: let
  callPackage = pkgs.callPackage;
in {
  # `default.nix` is already used for this file, so use a different name
  default = callPackage ./defaultShell.nix {};

  rust = callPackage ./rust.nix {};
}
