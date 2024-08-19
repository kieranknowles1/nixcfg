# Options that are used in multiple modules
{
  pkgs,
  config,
  hostConfig,
  lib,
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
      default = "gnome-console";
    };
  };

  config = {
    nixpkgs.overlays = hostConfig.nixpkgs.overlays;

    fonts.fontconfig.defaultFonts = {
      monospace = [config.custom.fonts.defaultMono];
    };

    home.packages = [
      config.custom.terminal.package
    ];

    # Add a command palette entry to rebuild while pulling,
    # this is a fairly common operation for me.
    custom.shortcuts.palette.actions = let
      terminal = lib.getExe config.custom.terminal.package;
      rebuild = lib.getExe pkgs.flake.rebuild;
    in
      lib.singleton {
        # We run in a terminal emulator to show output while running and
        # allow input for when sudo is required.
        # At least for kgx, passing additional arguments creates a one-off
        # terminal that only runs the command and goes read-only.
        action = [terminal "--" rebuild "--flake" hostConfig.custom.repoPath "pull"];
        description = "Update system from remote repository";
      };
  };
}
