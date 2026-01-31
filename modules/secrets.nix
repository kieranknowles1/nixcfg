let
  # Shared config for SOPS between NixOS and home-manager
  # These are just about identical, so we can share the module and avoid duplicate code
  module = {
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
      };
    };
  };
in {
  flake.nixosModules.secrets = module;
  flake.homeModules.secrets = module;
}
