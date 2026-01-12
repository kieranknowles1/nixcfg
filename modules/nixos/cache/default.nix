{
  config,
  lib,
  ...
}: {
  options.custom.cache = let
    inherit (lib) mkOption types;
  in {
    mode = mkOption {
      description = ''
        Whether this system sends to or receives from a self-hosted cache,
        or has no interaction with it.
      '';
      type = types.nullOr (types.enum ["send" "receive"]);
      default = null;
    };

    send = {
      privateKeySecret = mkOption {
        # TODO: Consider adding a lib.mkSopsOption
        description = ''
          Path to SOPS key containing a nix-serve private key.

          Generate using `nix-store --generate-binary-cache-key <hostname> private.pem public.pem`
          DO NOT commit `private.pem` unencrypted. DO commit `public.pem`.
        '';
        example = "cache/privateKey";
      };
    };

    receive = {
      publicKey = mkOption {
        description = ''
          Public key that matches the cache server's private key.
          This is safe to commit unencrypted.
        '';
        default = builtins.readFile ./publickey.pem;
      };

      server = mkOption {
        description = ''
          Domain name of the cache server.
        '';
        type = types.str;
        example = "https://cache.example.com";
        # TODO: HTTPs
        # TODO: Bind to domain name
        # TODO: Is this the right place to put the default?
        default = "http://192.168.1.169";
      };
    };
  };

  config = let
    cfg = config.custom.cache;
    send = cfg.mode == "send";
    receive = cfg.mode == "receive";
  in {
    sops.secrets = lib.mkIf send {
      "cache/privateKey".key = cfg.send.privateKeySecret;
    };

    services.nix-serve = {
      enable = send;
      secretKeyFile = config.sops.secrets."cache/privateKey".path;
      # TODO: Automatically allocate a port
      openFirewall = true;
      port = 80;
    };

    # TODO: Proper nginx module. Bind nix-serve to a subdomain
    # This is a workaround to allow nix-serve to bind to port 80
    boot.kernel.sysctl = lib.mkIf send {
      "net.ipv4.ip_unprivileged_port_start" = 0;
    };

    nix.settings = lib.mkIf receive {
      substituters = [
        cfg.receive.server
      ];
      trusted-public-keys = [
        cfg.receive.publicKey
      ];
    };
  };
}
