{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.trilium-client = let
    inherit (lib) mkOption mkEnableOption mkPackageOption types;
  in {
    # TODO: Would like to run this on a server for syncing
    enable = mkEnableOption "Trilium client";

    package = mkPackageOption pkgs "trilium-next-desktop" {};

    export = {
      destinationDir = mkOption {
        description = ''
          Destination directory for exported notes.
          Should be a Git repository dedicated for this purpose,
          and included in a backup solution.

          The repository will not be pushed automatically.
          Using GitHub or the like, even with a private repository,
          is not recommended.
        '';

        type = types.str;
        default = "/home/your-user/Documents/trilium-export";
      };

      apiKeySecret = mkOption {
        description = ''
          Path to a SOPS secret containing the Trilium API key.
        '';
        example = "trimium/apikey";
        type = types.str;
      };

      package = mkPackageOption pkgs.flake "export-notes" {};

      finalPackage = mkOption {
        description = "The final export-notes package, with destination and apiKeySecret set.";
        type = types.package;
        readOnly = true;
      };
    };
  };

  config = let
    cfg = config.custom.trilium-client;
  in
    lib.mkIf cfg.enable {
      custom.trilium-client = {
        # TODO: Move export to a server-side systemd timer. Do we even need the
        # client to be installed? Can we just use the web app?
        export = {
          destinationDir = lib.mkDefault "${config.home.homeDirectory}/Documents/trilium-export";
          finalPackage = cfg.export.package.override {
            inherit (cfg.export) destinationDir;
            apiKeyFile = config.sops.secrets."trilium/apikey".path;
          };
        };
      };

      sops.secrets."trilium/apikey".key = cfg.export.apiKeySecret;

      home.packages = [
        cfg.package
        cfg.export.finalPackage
      ];

      custom.shortcuts.palette.actions =
        lib.singleton
        {
          action = ["${cfg.export.finalPackage}/bin/export-notes"];
          description = "Export Trilium notes";
        };
    };
}
