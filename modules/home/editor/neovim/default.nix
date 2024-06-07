{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}: let
  nixvimLib = inputs.nixvim.lib.${system};
  nixvim = inputs.nixvim.legacyPackages.${system};
  nixvimModule = {
    inherit pkgs;
    module = import ./config;
    extraSpecialArgs = {

    };
  };
  nvim = nixvim.makeNixvimWithModule nixvimModule;
in {
  # TODO: Configure neovim
  config = lib.mkIf (config.custom.development.editor == "neovim") {
    home.packages = [
      nvim
    ];
  };
}
