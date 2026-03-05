# Network graph metadata. This is DESCRIPTIVE and not PRESCRIPTIVE.
# That is, it describes the hardware of a device but does not prescribe how it
# is configured nor enforce anything.
{
  config,
  lib,
  ...
}: {
  options.custom.topology = let
    inherit (lib) mkOption types;

    connectionType = types.submodule {
      options = {
        interface = mkOption {
          type = types.str;
          description = ''
            Interface on the other end of the connection.
          '';
        };

        node = mkOption {
          type = types.str;
          default = "router";
          description = ''
            Node on the other end of the connection.
          '';
        };
      };
    };

    interfaceType = types.submodule {
      options = {
        type = mkOption {
          type = types.enum ["ethernet" "wifi"];
          description = "Physical type of the interface";
        };

        physicalConnections = mkOption {
          type = types.listOf connectionType;
          default = [];
          description = ''
            Physical connections of the interface. E.g., to the router.
          '';
        };

        addresses = mkOption {
          type = types.listOf types.str;
          default = [];
          example = lib.literalExpression "[config.custom.networking.fixedIp]";
          description = ''
            Address this interface is connected to, or empty if not connected.
          '';
        };

        network = mkOption {
          type = types.str;
          default = "home";
          description = ''
            Network the interface is a part of.
          '';
        };
      };
    };
  in {
    summary = mkOption {
      type = types.str;
      description = "One-line summary of hardware configuration";
    };

    interfaces = mkOption {
      type = types.attrsOf interfaceType;
      description = ''
        Physical interfaces of the device describing its available ports,
        including unused ones.
      '';
    };
  };

  config = let
    cfg = config.custom.topology;
  in {
    topology.self = {
      hardware.info = cfg.summary;

      inherit (cfg) interfaces;
    };
  };
}
