{
  config,
  lib,
  ...
}: {
  options.custom.telly = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "Telly fuzzy find utilities";
  };

  config = let
    cfg = config.custom.telly;
  in
    lib.mkIf cfg.enable {
      programs.television = {
        enable = true;
        settings = builtins.fromTOML (builtins.readFile ./config.toml);
        # NuShell is supported for Ctrl+t - find file and Ctrl+r - search history
        # via /vendor/autoload
      };

      programs.nushell.extraConfig = builtins.readFile ./telly.nu;
    };
}
