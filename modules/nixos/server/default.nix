{
  lib,
  config,
  pkgs,
  ...
}: {
  options.custom.server = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "server hosting";

    hostname = mkOption {
      type = types.str;
      example = "example.com";
      description = "The hostname of the server";
    };

    root = mkOption {
      type = types.path;
      example = "/path/to/html";
      description = "The root directory for the server to serve on the domain";
    };

    email = mkOption {
      type = types.str;
      example = "user@example.com";
      description = "The email address to associate with certificate requests";
    };
  };

  config = let
    cfg = config.custom.server;
  in
    lib.mkIf cfg.enable {
      # TODO: Proper module for this
      custom.server.root = pkgs.flake.portfolio;

      services.nginx = {
        enable = true;
        virtualHosts."${cfg.hostname}" = {
          inherit (cfg) root;
          forceSSL = true; # Enable HTTPS and redirect HTTP to it
          enableACME = true; # Automatically obtain SSL certificates
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
