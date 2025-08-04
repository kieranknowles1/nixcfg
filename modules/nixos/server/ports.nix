{lib, ...}: {
  options.custom.server.ports = let
    inherit (lib) mkOption types;

    mkPortOption = protocol:
      mkOption {
        type = types.attrsOf types.port;
        description = "${protocol} port allocations.";
        default = {};
      };
  in {
    tcp = mkPortOption "tcp";
    udp = mkPortOption "udp";
  };

  config.custom.server.ports = {
    # Keep these sorted by port number
    tcp = {
      http = 80;
      https = 443;

      trilium = 8000;
    };
    udp = {
    };
  };
}
