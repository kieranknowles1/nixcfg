# Per-user
{
  lib,
  config,
  pkgs,
  hostConfig,
  ...
}: {
  options.custom.theme = {
    wallpaper = lib.mkOption {
      description = "The wallpaper to use. Ideally a PNG image to avoid compression artifacts.";
      type = lib.types.path;
    };
  };

  config = {
    stylix = {
      # base16Scheme isn't inherited if a wallpaper is set, so explicitly set it
      # to avoid one being generated
      base16Scheme = hostConfig.stylix.base16Scheme;
      image = config.custom.theme.wallpaper;
    };

  };
}
