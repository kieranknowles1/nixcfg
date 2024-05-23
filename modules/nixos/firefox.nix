# System level Firefox settings
# See also: ../home/firefox.nix
# TODO: Make the link clickable
{ config, pkgs, ...}:
{
  environment.gnome.excludePackages = with pkgs; [
    # GNOME's built-in browser
    epiphany
    # GNOME's document viewer. Firefox does a better job at this
    evince
  ];

  # Install firefox. TODO: Do with home manager and enable extensions
  programs.firefox = {
    enable = true;

    policies = {
      # Updates are managed by Nix
      DisableAppUpdate = true;
      DisableTelemetry = true;
      # Extensions are also managed
      ExtensionUpdate = false;
      # I use Bitwarden for this
      PasswordManagerEnabled = false;
    };
  };
}