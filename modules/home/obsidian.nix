{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.obsidian = let
    inherit (lib) mkEnableOption mkPackageOption;
  in {
    enable = mkEnableOption "Obsidian Notes";
    package = mkPackageOption pkgs "obsidian" {};
  };

  config = let
    cfg = config.custom.obsidian;
  in
    lib.mkIf cfg.enable {
      # We could get much more complicated and configure vaults/plugins, but
      # Git does this all well enough
      programs.obsidian = cfg;
    };
}
