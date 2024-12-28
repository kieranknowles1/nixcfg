{
  config,
  lib,
  pkgs,
  hostConfig,
  ...
}: {
  options.custom.editor.neovim = {
    enable = lib.mkEnableOption "NeoVim";
  };

  config = lib.mkIf config.custom.editor.neovim.enable {
    # home.packages = [
    #   (pkgs.flake.nixvim.extend {custom.optimise = true;})
    # ];
    programs.neovim = {
      enable = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };

    home.shellAliases = let
      flake = config.custom.fullRepoPath;
      host = hostConfig.networking.hostName;
      user = config.custom.userDetails.userName;
    in {
      # Helper to run the latest nvim without a rebuild
      nvimd = "nix run ${flake}#nixosConfigurations.${host}.config.home-manager.users.${user}.programs.neovim.finalPackage";
    };

    # # Don't manage anything with Nix for now
    # # TODO: Manage configs/plugins with Nix?
    # xdg.configFile."nvim" = {
    #   source = ./config;
    #   recursive = true;
    # };
  };
}
