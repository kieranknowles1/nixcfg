{
  pkgs,
  config,
  lib,
  ...
}: {
  # TODO: Maybe allow multiple editors to be installed at the same time
  config = lib.mkIf (config.custom.editor == "neovim") {
    programs.neovim = {
      enable = true;
    };

    # Don't manage anything with Nix for this PR
    # TODO: Manage configs/plugins with Nix
    xdg.configFile."nvim" = {
      source = ./config;
      recursive = true;
    };
  };
}
