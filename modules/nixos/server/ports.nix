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
    # if there's a conflict bump until a free port is found.
    tcp = {
      ssh = 22;
      dns = 53;
      http = 80;
      https = 443;

      immich = 2283;

      adguard = 3000;
      actual = 3001;

      postgresql = 5432;

      archiveteam = 8001;
      trilium = 8080;
      homepage = 8082;

      minecraft = 25565;

      paperless = 28981;

      glances = 61208;
    };

    udp = {
      dns = 53;

      minecraft = 25565;
    };
  };
}
