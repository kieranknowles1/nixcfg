# Options that are used in multiple modules
{
  pkgs,
  config,
  hostConfig,
  lib,
  flake,
  ...
}: {
  options.custom = {
    fonts = {
      defaultMono = lib.mkOption {
        description = "Default monospace font";
        type = lib.types.str;
        default = "DejaVuSansMono";
      };
    };

    terminal.package = lib.mkPackageOption pkgs "terminal" {
      default = "gnome-terminal";
    };
  };

  config = {
    fonts.fontconfig.defaultFonts = {
      monospace = [config.custom.fonts.defaultMono];
    };

    home.packages = [
      config.custom.terminal.package
    ];

    # Add a command palette entry to rebuild while pulling,
    # this is a fairly common operation for me.
    custom.shortcuts.palette.actions = let
      flakePkgs = flake.packages.${hostConfig.nixpkgs.hostPlatform.system};

      terminal = lib.getExe config.custom.terminal.package;
      rebuild = lib.getExe flakePkgs.rebuild;
    in lib.singleton {
      # We run in a terminal emulator to show output while running
      action = "${terminal} ${rebuild} --flake ${hostConfig.custom.repoPath} pull";
      description = "Update system from remote repository";
    };
  };
}
