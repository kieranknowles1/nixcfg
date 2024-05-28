# Install tools needed for a development environment
{ config, lib, pkgs, ... }:
{
  options.custom = {
    development.enable = lib.mkEnableOption "development tools";
  };

  config = lib.mkIf config.custom.development.enable {
    environment.systemPackages = with pkgs; [
      # git # In core.nix for reasons explained there
      nil # Language server for Nix
    ];
  };
}
