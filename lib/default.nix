{
  nixpkgs,
  nixpkgs-unstable,
  self,
  ...
} @ inputs: let
  pkgs = import nixpkgs {system = "x86_64-linux";};

  callPackage = pkgs.lib.customisation.callPackageWith (pkgs // inputs);
in {
  attrset = import ./attrset.nix;
  docs = callPackage ./docs.nix {};
  # We need to import nixpkgs and nixpkgs-unstable for the host's system type
  host = import ./host.nix {inherit nixpkgs nixpkgs-unstable self inputs;};
  image = import ./image.nix {inherit pkgs;};
  package = import ./package.nix {inherit pkgs;};
  shell = import ./shell.nix {inherit pkgs;};
}
