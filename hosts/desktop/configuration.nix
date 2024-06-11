# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ ... }:

{
  # Enable everything needed for this configuration
  config.custom = {
    development = {
      enable = true;
      meta.enable = true;
      modding.enable = true;
    };
    games.enable = true;
    nvidia.enable = true;

    hyprland = {
      monitors = [
        # Primary monitor
        "DP-1,2560x1440,0x0,1"
        # Secondary monitor on the left and a bit down
        "HDMI-A-2,1920x1080,-1920x500,1"
        # Weird extra monitor from (Nvidia drivers?)
        "Unknown-1,disable"
      ];
    };
  };
}
