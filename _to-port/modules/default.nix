{
  flake = {
    nixosModules.default = import ./nixos;
    homeModules.default = import ./home;
  };
}
