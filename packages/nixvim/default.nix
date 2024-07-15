# Package to build our nixvim environment
# We use a package rather than nix module to allow for rapid iteration,
# as we only need to rebuild the package rather than the entire system
{
  pkgs,
  inputs,
}:
inputs.nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule {
  module = {
    opts = {
      number = true;

      # Use two spaces for tabs
      shiftwidth = 2;
    };

    colorschemes.gruvbox.enable = true;

    plugins = {
      lualine.enable = true;
    };
  };
}
