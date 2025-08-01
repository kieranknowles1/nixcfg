# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  config,
  self,
  nixos-raspberrypi,
  inputs,
  ...
}: {
  imports = with nixos-raspberrypi.nixosModules; [
    ./hardware-configuration.nix
    {
      boot.kernelPackages = inputs.nixos-raspberrypi-kernellock.packages.aarch64-linux.linuxPackages_rpi5;

      custom = {
        users = {
          users.kieran = import ../../users/kieran {inherit pkgs config self;};
        };

        # Renewal is manual, but I don't really care because certs last 15 years
        # TODO: We should really be automating this and revoke the 15 year one
        secrets = {
          ageKeyFile = "/home/kieran/.config/sops/age/keys.txt";
          file = ./secrets.yaml;
        };

        server = {
          root = {
            root = pkgs.flake.portfolio;
            cache.enable = true;
          };
          ssl = {
            publicKeyFile = ./selwonk.uk.pem;
            privateKeySecret = "ssl/private-key";
          };
        };
      };
    }
    # Base support
    raspberry-pi-5.base
    # Display support (may be unnecessary since we are a server)
    raspberry-pi-5.display-vc4
  ];

  # Enable everything needed for this configuration
  config.custom = self.lib.host.readTomlFile ./config.toml;
}
