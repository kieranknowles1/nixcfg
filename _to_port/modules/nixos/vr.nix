{
  lib,
  config,
  pkgs,
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
      # OpenXR server
      services.monado = {
        enable = true;
        defaultRuntime = true;
      };

      # Translate OpenVR to OpenXR
      home-manager.sharedModules = lib.singleton ({config, ...}: {
        xdg.configFile."openvr/openvrpaths.vrpath".text = builtins.toJSON {
          config = ["${config.xdg.dataHome}/Steam/config"];
          external_drivers = null;
          jsonid = "vrpathreg";
          log = ["${config.xdg.dataHome}/Steam/logs"];
          runtime = ["${pkgs.opencomposite}/lib/opencomposite"];
          version = 1;
        };
      });

      environment.systemPackages = with pkgs; [
        # Lighthouse based tracking
        libsurvive
        opencomposite
      ];
    };
}
