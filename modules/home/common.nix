# Options that are used in multiple modules
{
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
  };

  config = {
    fonts.fontconfig.defaultFonts = {
      monospace = [config.custom.fonts.defaultMono];
    };
  };
}
