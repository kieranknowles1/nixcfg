{
  config,
  lib,
  pkgs,
  hostConfig,
  ...
}: {
  options.custom.editor.neovim = let
    inherit (lib) mkOption mkEnableOption mkPackageOption types;
  in {
    enable = mkEnableOption "NeoVim";
    desktopFile = mkOption {
      description = "Name of the .desktop file";
      default = "nvim.desktop";
      type = types.str;
      readOnly = true;
    };

    command = mkOption {
      description = "Command to run the editor";
      default = "nvim";
      type = types.str;
      readOnly = true;
    };

    package = mkPackageOption pkgs.flake "nixvim" {};
  };

  config = let
    cfg = config.custom.editor.neovim;

    # Fancy GUI, included on all desktops
    neovideOpt = lib.optional hostConfig.custom.features.desktop pkgs.neovide;
  in
    lib.mkIf cfg.enable {
      # We can't use home-manager to deploy, as nixvim is incompatible with its
      # wrapper
      home.packages = [cfg.package] ++ neovideOpt;
    };
}
