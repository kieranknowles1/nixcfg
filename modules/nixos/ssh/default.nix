{
  config,
  lib,
  ...
}: {
  config = {
    services.openssh = {
      enable = true;

      # Only allow public key authentication
      settings.PasswordAuthentication = false;

      # Install signatures of all my hosts and some common remotes (e.g., github.com)
      # These are read from [[./hosts]] where the file name is the hostname and the content is the ed25519 signature
      # To get the signature of a host, run `ssh-keyscan ${hostname}` which will work for both local and remote hosts
      knownHosts = builtins.mapAttrs (name: value: {
        hostNames = [name];
        publicKeyFile = ./hosts/${name};
      }) (builtins.readDir ./hosts);
    };

    # Accept any of my public keys, read from [[./keys]]
    # TODO: Secret management to automatically add the private keys
    # TODO: Should this be in the user's config? authorized_keys is a user-level setting
    # TODO: Update keys/hosts for new hostnames
    users.users =
      lib.attrsets.mapAttrs (name: user: {
        openssh.authorizedKeys.keyFiles =
          builtins.map
          (name: ./keys/${name})
          (builtins.attrNames (builtins.readDir ./keys));
      })
      config.custom.user;
  };
}
