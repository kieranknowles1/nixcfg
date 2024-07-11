# Options that are used in multiple modules
{
  config,
  lib,
  ...
}: {
  options.custom = {
    # TODO: Remove this in favour of the host's configuration
    repoPath = lib.mkOption {
      description = "Path to the repository on disk, relative to the home directory";
      type = lib.types.str;
    };

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
