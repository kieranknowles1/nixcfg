{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.server.postgresql = let
    inherit (lib) mkOption mkEnableOption mkPackageOption types;
  in {
    enable = mkEnableOption "PostgreSQL";

    dataDir = mkOption {
      type = types.path;
      description = "The directory where PostgreSQL data will be stored.";
    };

    package = mkPackageOption pkgs "postgresql_16" {
      extraDescription = ''
        Before upgrading, make sure to read the
         for instructions
        on how to upgrade safely.
      '';
    };
  };

  config = let
    cfg = config.custom.server;
    cfgp = cfg.postgresql;
  in
    lib.mkIf cfgp.enable {
      custom.server.postgresql = {
        dataDir = "${cfg.data.baseDirectory}/postgresql";
      };

      services.postgresql = {
        # This module only exists so that others can depend on it and is thus
        # not configured by default.
        inherit (cfgp) dataDir package;
        enable = true;

        # HACK: Workaround to make postgres use our overlays
        extensions = lib.mkForce (_ps:
          with pkgs.postgresql16Packages; [
            pgvecto-rs
          ]);
      };
    };
}
