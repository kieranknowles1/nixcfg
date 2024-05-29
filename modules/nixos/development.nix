# Install tools needed for a development environment
{ config, lib, pkgs, flake, ... }: let
  ifEnabled = flake.lib.package.ifEnabled;
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
    ] ++ (ifEnabled config.custom.development.node.enable [
      nodejs
    ]);
  };
}
