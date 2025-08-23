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
    # Keep these sorted by port number. Include anything that could be allocated
    # on the server. Use a service's default port from nixpkgs if possible,
    # but change if necessary.
    # If a service supports unix sockets, use them instead of TCP.
    tcp = {
      ssh = 22;
      http = 80;
      https = 443;

      immich = 2283;

      postgresql = 5432;

      trilium = 8080;

      paperless = 28981;
    };
    udp = {
    };
  };
}
