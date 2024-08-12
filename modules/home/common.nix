# Options that are used in multiple modules
{
  pkgs,
  config,
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
  };
}
