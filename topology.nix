{
  inputs,
  self,
  lib,
  flake-parts-lib,
  ...
}: {
  imports = lib.singleton (flake-parts-lib.mkTransposedPerSystemModule {
    name = "topology";
    option = let
      inherit (lib) mkOption types;
    in
      mkOption {
        type = types.lazyAttrsOf types.anything;
        default = {};
        description = ''
          Network topology of the flake.
        '';
      };
    file = ./.;
  });

  perSystem = {pkgs, ...}: {
    topology = import inputs.nix-topology {
      inherit pkgs;
      modules = lib.singleton ({config, ...}: {
        inherit (self) nixosConfigurations;

        networks.home = {
          name = "Home Network";
          cidrv4 = "192.168.1.1/24";
        };

        nodes = let
          inherit (config.lib.topology) mkConnection mkRouter mkInternet;
        in {
          internet = mkInternet {};

          router = mkRouter "Router" {
            # TODO: Include cloud?
            # TODO: Clean up server, display nginx as a proxy
            interfaceGroups = [["eth1" "eth2" "eth3" "eth4" "wlan1"] ["wan1"]];

            interfaces.wan1.physicalConnections = [(mkConnection "internet" "*")];
          };
        };
      });
    };
  };
}
