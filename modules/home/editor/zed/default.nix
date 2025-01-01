{
  pkgs,
  lib,
  config,
  hostConfig,
  ...
}: {
  options.custom.editor.zed = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "Zed";
  };

  config = let
    cfg = config.custom.editor.zed;
  in
    lib.mkIf cfg.enable {
      assertions = lib.singleton {
        assertion = hostConfig.custom.features.desktop;
        message = "Zed requires a desktop environment.";
      };

      home.packages = with pkgs; [
        zed-editor
        # Dependencies for language servers
        nixd
      ];
    };
}
