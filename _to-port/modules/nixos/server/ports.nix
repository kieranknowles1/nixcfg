{lib, ...}: {
  options.custom = let
    inherit (lib) mkOption types;

    mkPortOption = protocol:
      mkOption {
        type = types.attrsOf types.port;
        description = "${protocol} port allocations.";
        default = {};
      };
  in {
    server.ports = {
      tcp = mkPortOption "tcp";
      udp = mkPortOption "udp";
    };

    gids = mkOption {
      type = types.attrsOf types.int;
      description = ''
        Group IDs. Should only be used in exceptional circumstances where
        services REQUIRE integer IDs instead of names. Normally, you should
        let NixOS allocate them automatically.
      '';
      default = {};
    };
  };

  config.custom = {
    # Keep these sorted by port number. Include anything that could be allocated
    # on the server. Use a service's default port from nixpkgs if possible,
    # if there's a conflict bump until a free port is found.
    server.ports.tcp = {
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

    server.ports.udp = {
      dns = 53;

      minecraft = 25565;
    };

    # Keep these sorted by ID number and justify each
    gids = {
      # Start at 32000. NixOS uses a couple of the 31k range itself, so this
      # seems like a safe range that shouldn't conflict
      # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/misc/ids.nix

      # Copyparty's `gid` chown option requires an ID, names are not accepted.
      immich-copyparty = 32000;
    };
  };
}
