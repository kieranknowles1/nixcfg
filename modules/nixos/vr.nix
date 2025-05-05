# https://wiki.nixos.org/wiki/VR
{
  lib,
  config,
  ...
}: {
  options.custom.vr = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "VR support";
  };

  config = let
    cfg = config.custom.vr;
  in
    lib.mkIf cfg.enable {
      services.monado = {
        enable = true;
        defaultRuntime = true;
      };
    };
}
