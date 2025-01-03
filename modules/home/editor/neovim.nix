{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.editor.neovim = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "NeoVim";
    desktopFile = mkOption {
      description = "Name of the .desktop file";
      default = "nvim.desktop";
      type = types.str;
      readOnly = true;
    };
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
