# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  config,
  self,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    {
      custom = {
        users = {
          users.kieran = import ../../users/kieran {inherit pkgs config self;};
          sharedConfig.custom = self.lib.host.readTomlFile ./user-config.toml;
        };

        secrets = {
          ageKeyFile = "/home/kieran/.config/sops/age/keys.txt";
          file = ./secrets.yaml;
        };
      };
    }
  ];

  # Enable everything needed for this configuration
  config.custom = self.lib.host.readTomlFile ./config.toml;
}
