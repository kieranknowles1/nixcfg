# SSH configuration
# To add a known host, run `ssh-keyscan ${hostname}` and place the output in ./hosts/${hostname} (the file name is the full domain name)
# The file should contain the remainder of the `ssh-ed25519` line
# Similarly, public keys should be copied from ~/.ssh/id_ed25519.pub to ./keys/${hostname}.pub
{ lib, ... }:
{
  options.custom.ssh =
    let
      inherit (lib) mkOption types;
    in
    {
      keyOwners = mkOption {
        type = types.attrsOf (types.listOf types.str);
        description = "Map of public key owners to their keys";
        default = { };
        example = {
          "user@example.com" = [
            "ssh-ed25519 ABC123"
            "ssh-ed25519 XYZ789"
          ];
        };
      };
    };

  config = {
    custom.ssh.keyOwners."kieranknowles11@hotmail.co.uk" = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBgWyhSODClMBaiNI4EjqTeWUxnBjjKV9zyyVHh8DV1f kieran@canterbury"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBpPVX1L4/sGfQv6grn6dgiKQUPJ+/TSL9BL+vXgajlj kieran@tycho"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDFUXZ7Ui31mraAmFucCKSOgISaqnbckwwsLg8ZbIaXY kieran@rocinante"
    ];

    services.openssh = {
      enable = true;

      # Only allow public key authentication
      settings.PasswordAuthentication = false;

      # Install signatures of all my hosts and some common remotes (e.g., github.com)
      # These are read from [[./hosts]] where the file name is the hostname and the content is the ed25519 signature
      # To get the signature of a host, run `ssh-keyscan ${hostname}` which will work for both local and remote hosts
      knownHosts = builtins.mapAttrs (name: _value: {
        hostNames = [ name ];
        publicKeyFile = ./hosts/${name};
      }) (builtins.readDir ./hosts);
    };
  };
}
