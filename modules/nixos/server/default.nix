{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./docs.nix
  ];

  options.custom.server = let
    inherit (lib) mkOption mkEnableOption types;

    vhostOpts = {
      root = mkOption {
        type = types.path;
        example = "/path/to/html";
        description = "The root directory to be served";
      };
    };

    subdomainType = types.submodule {
      options = vhostOpts;
    };
  in {
    enable = mkEnableOption "server hosting";

    hostname = mkOption {
      type = types.str;
      example = "example.com";
      description = "The domain name of the server";
    };

    email = mkOption {
      type = types.str;
      example = "user@example.com";
      description = "The email address to associate with certificate requests";
    };

    root = vhostOpts;
    subdomains = mkOption {
      type = types.attrsOf subdomainType;
      default = {};
      description = "Subdomains to serve on the server";
    };
  };

  config = let
    cfg = config.custom.server;

    subhosts =
      lib.attrsets.mapAttrs' (name: subdomain: {
        name = "${name}.${cfg.hostname}";
        value = mkVhost subdomain;
      })
      cfg.subdomains;

    mkVhost = subdomain: {
      inherit (subdomain) root;
      forceSSL = true; # Enable HTTPS and redirect HTTP to it
      enableACME = true; # Automatically obtain SSL certificates
    };
  in
    lib.mkIf cfg.enable {
      # TODO: Proper module for this
      custom.server.root.root = pkgs.flake.portfolio;

      services.nginx = {
        enable = true;

        virtualHosts =
          subhosts
          // {
            "${cfg.hostname}" = mkVhost cfg.root;
          };
      };

      security.acme = {
        acceptTerms = true;
        defaults.email = cfg.email;
      };

      # HTTP and HTTPS
      networking.firewall.allowedTCPPorts = [80 443];
    };
}
