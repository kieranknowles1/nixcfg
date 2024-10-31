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
        user.kieran = import "${self}/users/kieran" {inherit pkgs config self;};

        secrets = {
          ageKeyFile = "/home/kieran/.config/sops/age/keys.txt";
          file = ./secrets.yaml;
        };
      };

      # TODO: Temp code until this is on a server
      environment.systemPackages = [
        pkgs.flake.trilium-next-desktop
      ];
    }
  ];

  # Enable everything needed for this configuration
  config.custom = self.lib.host.readTomlFile ./config.toml;
}
