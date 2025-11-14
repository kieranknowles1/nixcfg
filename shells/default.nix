{
  perSystem = {pkgs, ...}: let
    inherit (pkgs) callPackage;
  in {
    devShells = rec {
      # `default.nix` is already used for this file, so use a different name
      default = callPackage ./defaultShell.nix {};
      cmake = callPackage ./cmake.nix {};
      homepage = callPackage ./homepage.nix {inherit rust;};
      rust = callPackage ./rust.nix {};
    };
  };
}
