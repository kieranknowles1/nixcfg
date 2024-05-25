# Install tools needed for a development environment
{ config, lib, pkgs, ... }:
{
  options.custom = {
    development.enable = lib.mkEnableOption "development tools";
  };

  # TODO: Conditionally install VSCode. Tricky as it's handled by Home Manager.
  config = lib.mkIf config.custom.development.enable {
    environment.systemPackages = with pkgs; [
      # git # In core.nix for reasons explained there
      nil # Language server for Nix
    ];
  };
}
