{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.server.authelia = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "Authelia";

    subdomain = mkOption {
      type = types.str;
      default = "auth";
      description = "The subdomain for Authelia";
    };

    socket = mkOption {
      type = types.str;
      default = "/var/run/authelia/authelia.sock";
      description = "The socket for Authelia";
    };

    secrets = let
      mkSecretOption = name: default:
        mkOption {
          inherit default;
          type = types.str;
          description = "SOPS secret path for ${name}";
        };
    in {
      jwtSecret = mkSecretOption ''
        jwt_secret. Should be a random ASCII string.

        See https://www.authelia.com/configuration/identity-validation/reset-password/#jwt_secret
      '' "authelia/jwtSecret";
      storageEncryptionKey = mkSecretOption ''
        Storage encryption key. Should be a random ASCII string.

        See https://www.authelia.com/configuration/storage/introduction/#encryption_key
      '' "authelia/storageEncryptionKey";
    };
  };

  config = let
    cfg = config.custom.server;
    cfga = cfg.authelia;
  in
    lib.mkIf cfga.enable {
      custom.server = {
        subdomains.${cfga.subdomain} = {
          proxySocket = cfga.socket;
        };
      };

      sops.secrets = let
        provisionSecret = key: {
          inherit key;
          # This would need changing if we want to handle multiple instances
          owner = config.services.authelia.instances.default.user;
        };
      in {
        "authelia/jwtSecret" = provisionSecret cfga.secrets.jwtSecret;
        "authelia/storageEncryptionKey" = provisionSecret cfga.secrets.storageEncryptionKey;
      };

      # We're only protecting the one domain, so no
      # need for additional instances
      services.authelia.instances.default = {
        enable = true;

        settings = let
          convertedYaml = pkgs.runCommand "authelia-settings.json" {} ''
            cat ${./config.yml} | ${pkgs.yj}/bin/yj > $out
          '';
          settings = builtins.fromJSON (builtins.readFile convertedYaml);
        in
          lib.mkMerge [
            settings
            {
              server.address = "unix://${cfga.socket}";
            }
          ];

        secrets = let
          sec = config.sops.secrets;
        in {
          jwtSecretFile = sec."authelia/jwtSecret".path;
          storageEncryptionKeyFile = sec."authelia/storageEncryptionKey".path;
        };
      };
    };
}
