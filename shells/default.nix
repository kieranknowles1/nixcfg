{
  perSystem =
    { pkgs, ... }:
    let
      inherit (pkgs) callPackage;
    in
    {
      devShells = {
        # `default.nix` is already used for this file, so use a different name
        default = callPackage ./defaultShell.nix { };
        cmake = callPackage ./cmake.nix { };
        rust = callPackage ./rust.nix { };
      };
    };
}
