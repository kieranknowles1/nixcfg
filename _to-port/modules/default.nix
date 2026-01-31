{
  flake = {
    nixosModules.default = import ./nixos;
    homeManagerModules.default = import ./home;
  };
}
