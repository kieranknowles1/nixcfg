# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  config,
  flake,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Enable everything needed for this configuration
  config.custom =
    {
      user.kieran = import ../../users/kieran {inherit pkgs config flake;};
    }
    // builtins.fromTOML (builtins.readFile ./config.toml);
}
