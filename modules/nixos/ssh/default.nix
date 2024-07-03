{
  ...
}: {
  config = {
    services.openssh = {
      enable = true;

      # Only allow public key authentication
      settings.PasswordAuthentication = false;

      # Install signatures of all my hosts
      # knownHosts =
    };

    # Accept any of my public keys, read from [[./keys]]
    # TODO: Don't hardcode the username, maybe do this in mkUser
    # TODO: Secret management to automatically add the private keys
    users.users.kieran.openssh.authorizedKeys.keyFiles = builtins.map (name: ./keys/${name}) (builtins.attrNames (builtins.readDir ./keys));
  };
}
