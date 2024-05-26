# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs-unstable,
  pkgs,
  ...
}:

{
  # Enable everything needed for this configuration
  # TODO: Deduplicate configuration.nix. It should only contain config.custom
  custom = {
    office.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    file
    fsearch
    gnome.zenity # Need this for MO2 installer
    home-manager
    p7zip
    # Use bleeding-edge wine
    pkgs-unstable.wine
    pkgs-unstable.winetricks
  ];

  fonts.packages = with pkgs; [
    nerdfonts # Patched fonts with icons used by Starship in Unicode's Private Use Area
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
