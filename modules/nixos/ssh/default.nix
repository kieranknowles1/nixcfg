{
  ...
}: {
  config = {
    services.openssh = {
      enable = true;

      # Only allow public key authentication
      settings.PasswordAuthentication = false;

      # Install signatures of all my hosts, read from [[./hosts]]
      # File name is the hostname, content is the signature returned by `ssh-keyscan ${hostname}`
      # this will work for localhost and remote hosts
      # Multiple algorithms will be listed, prefer "ssh-ed25519" as it is the most secure
      knownHosts = builtins.mapAttrs (name: value: {
        hostNames = [name];
        publicKeyFile = ./hosts/${name};
      }) (builtins.readDir ./hosts);
    };

    # Accept any of my public keys, read from [[./keys]]
    # TODO: Don't hardcode the username, maybe do this in mkUser
    # TODO: Secret management to automatically add the private keys
    users.users.kieran.openssh.authorizedKeys.keyFiles = builtins.map (name: ./keys/${name}) (builtins.attrNames (builtins.readDir ./keys));
  };
}
