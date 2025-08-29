{
  config,
  lib,
  ...
}:
{
  options.custom.telly =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "Telly";
    };

  config =
    let
      cfg = config.custom.telly;
    in
    lib.mkIf cfg.enable {
      programs.television = {
        enable = true;
        settings = builtins.fromTOML (builtins.readFile ./config.toml);
        # TODO: Nushell integration once its supported for ctrl+t completions
      };

      programs.nushell.extraConfig = builtins.readFile ./telly.nu;
    };
}
