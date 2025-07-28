{
  config,
  lib,
  ...
}: {
  options.custom.compat = let
    inherit (lib) mkEnableOption;
  in {
    appimage.enable = mkEnableOption "appimage support";
  };

  config = let
    cfg = config.custom.compat;
  in {
    programs.appimage = {
      inherit (cfg.appimage) enable;
      binfmt = cfg.appimage.enable;
    };
  };
}
