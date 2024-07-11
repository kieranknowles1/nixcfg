{
  pkgs,
  config,
  modulesPath,
  ...
}: {
  imports = [
    # Allow building an ISO image. This can be built with "nix run nixpkgs#nixos-generators -- --format iso --flake .#server -o result".
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # TODO: Use TOML instead of Nix
  config.custom = {
    user.kieran = import ../../users/kieran.nix {inherit pkgs config;};
    deviceType = "server";

    repoPath = "/home/kieran/nixcfg";
  };
}
# TODO: Implement the configuration of the server.

