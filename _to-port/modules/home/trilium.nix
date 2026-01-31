{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.trilium-client = let
    inherit (lib) mkEnableOption mkPackageOption;
  in {
    enable = mkEnableOption "Trilium client";
    package = mkPackageOption pkgs "trilium-next-desktop" {};
  };

  config = let
    cfg = config.custom.trilium-client;
  in
    lib.mkIf cfg.enable {
      home.packages = [
        cfg.package
      ];
    };
}
