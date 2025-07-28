{
  config,
  lib,
  ...
}: {
  options.custom.compat = let
    inherit (lib) mkEnableOption;
  in {
    # Disabled by default as it brings in a dependency on SDL2
    appimage.enable = mkEnableOption "appimage support";
    arm.enable = mkEnableOption "arm support";
  };

  config = let
    cfg = config.custom.compat;
  in {
    programs.appimage = {
      inherit (cfg.appimage) enable;
      binfmt = cfg.appimage.enable;
    };

    boot.binfmt.emulatedSystems = lib.optional cfg.arm.enable "aarch64-linux";
  };
}
