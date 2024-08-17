{
  pkgs,
  config,
  modulesPath,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    # Allow building an ISO image. This can be built with "nix run nixpkgs#nixos-generators -- --format iso --flake .#server -o result".
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  config.custom =
    {
      user.kieran = import ../../users/kieran {inherit pkgs config;};
    }
    // builtins.fromTOML (builtins.readFile ./config.toml);
}
# TODO: Implement the configuration of the server.

