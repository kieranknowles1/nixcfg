{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.trilium-client = let
    inherit (lib) mkEnableOption;
  in {
    # TODO: Would like to run this on a server for syncing
    enable = mkEnableOption "Trilium client";
  };

  config = let
    cfg = config.custom.trilium-client;
  in
    lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        trilium-desktop
      ];

      custom.shortcuts.palette.actions = [
        {
          action = [
            (lib.getExe pkgs.flake.export-notes)
          ];
          description = "Export Trilium notes";
        }
      ];
    };
}
