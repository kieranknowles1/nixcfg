# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  config,
  ...
}: {
  # Enable everything needed for this configuration
  config.custom = {
    user.kieran = import ../../users/kieran.nix {inherit pkgs config;};

    deviceType = "desktop";
    repoPath = "/home/kieran/Documents/src/nixcfg";

    office.enable = true;

    printing.enable = true;

    development = {
      enable = true;
      node.enable = true;
      meta.enable = true;
    };
  };
}
