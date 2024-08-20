{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.editor.neovim = {
    enable = lib.mkEnableOption "NeoVim";
  };

  config = lib.mkIf config.custom.editor.neovim.enable {
    home.packages = [
      (pkgs.flake.nixvim.extend {custom.optimise = true;})
    ];
    # programs.neovim = {
    #   enable = true;

    #   viAlias = true;
    #   vimAlias = true;
    #   vimdiffAlias = true;
    # };

    # # Don't manage anything with Nix for now
    # # TODO: Manage configs/plugins with Nix?
    # xdg.configFile."nvim" = {
    #   source = ./config;
    #   recursive = true;
    # };
  };
}
