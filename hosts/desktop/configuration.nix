# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{...}: {
  # Enable everything needed for this configuration
  config.custom = {
    deviceType = "desktop";
    repoPath = "/home/kieran/Documents/src/nixcfg";

    development = {
      enable = true;
      meta.enable = true;
      modding.enable = true;
    };
    games.enable = true;
    nvidia.enable = true;
  };
}
