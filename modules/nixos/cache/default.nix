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
  };

  config = let
    cfg = config.custom.cache;
    send = cfg.mode == "send";
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
  };
}
