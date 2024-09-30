{inputs, ...}: let
  # TODO: lib shouldn't depend on system type
  pkgs = import inputs.nixpkgs {system = "x86_64-linux";};

  callPackage = pkgs.lib.customisation.callPackageWith (pkgs // inputs);
in {
  flake.lib = {
    attrset = callPackage ./attrset.nix {};
    docs = callPackage ./docs.nix {};
    host = callPackage ./host.nix {inherit inputs;};
    image = callPackage ./image.nix {};
    package = callPackage ./package.nix {};
    shell = callPackage ./shell.nix {};
  };
}
