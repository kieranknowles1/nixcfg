flake: {
  default = final: prev: let
    system = prev.stdenv.hostPlatform.system;
    flakePkgs = flake.packages.${system};
  in {
    # Expose our pkgs and lib as an overlay
    flake =
      flakePkgs
      // {
        lib = flake.lib;
      };
  };
}
