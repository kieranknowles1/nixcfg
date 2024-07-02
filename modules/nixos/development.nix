# Install tools needed for a development environment
{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom = {
    development = {
      enable = lib.mkEnableOption "development tools";

      meta.enable = lib.mkEnableOption "development of this repository";
      modding.enable = lib.mkEnableOption "modding tools";
      node.enable = lib.mkEnableOption "node.js";
      remote.enable = lib.mkEnableOption "remote development over SSH";
    };
  };

  config = lib.mkIf config.custom.development.enable {
    environment.systemPackages = with pkgs;
      [
        # git # In core.nix for reasons explained there
      ]
      ++ (lib.optionals config.custom.development.meta.enable [
        nil # Language server for Nix
      ])
      ++ (lib.optionals config.custom.development.node.enable [
        nodejs
      ]);
  };
}
