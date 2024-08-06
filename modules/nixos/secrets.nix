# Provision secrets using SOPS
# These will be available in the `/run/secrets` directory and owned by root
{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
  options.custom.secrets = {
    ageKeyFile = lib.mkOption {
      description = "The absolute path to the age key file. This is NOT a Nix path, as then we would be storing the key in the Nix store. Should be able to decrypt the secrets file.";
      type = lib.types.str;
      example = "/home/bob/.config/sops/age/keys.txt";
    };

    file = lib.mkOption {
      description = "The Nix path to the secrets file. This is encrypted, and therefore safe to store in the Nix store or Git.";
      type = lib.types.path;
    };
  };

  config = let
    cfg = config.custom.secrets;
  in {
    sops = {
      defaultSopsFile = cfg.file;
      defaultSopsFormat = "yaml";

      age.keyFile = cfg.ageKeyFile;

      secrets."backup/password" = {};
    };
  };
}
