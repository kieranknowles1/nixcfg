# Install tools needed for a development environment
{ config, lib, pkgs, flake, ... }: let
  optionalPackages = flake.lib.package.optionalPackages;
in {
  options.custom = {
    development = {
      enable = lib.mkEnableOption "development tools";
      node.enable = lib.mkEnableOption "node.js";
    };
  };

  config = lib.mkIf config.custom.development.enable {
    environment.systemPackages = with pkgs; [
      # git # In core.nix for reasons explained there
      nil # Language server for Nix
    ] ++ (optionalPackages config.custom.development.node.enable [
      nodejs
    ]);
  };
}
