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
        users.users.kieran = import "${self}/users/kieran" {inherit pkgs config self;};

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
