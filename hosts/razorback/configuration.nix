{
  # This configuration is built into an ISO using nixos-generators
  # To generate, run `nixos-generate --format iso --flake .#razorback --out-link razorback.iso`
  # Building tested on `Rocinante` with 32GB of RAM. `Canterbury` has 8GB and failed.

  system = "aarch64-linux";

  config = {
    pkgs,
    config,
    modulesPath,
    flake,
    ...
  }: {
    imports = [
      ./hardware-configuration.nix
    ];

    # Cross-compile from x86_64-linux to aarch64-linux. This seems to greatly increase
    # RAM usage, but we need either this or a dedicated build machine.
    # TODO: Look into https://nix.dev/manual/nix/2.18/advanced-topics/distributed-builds
    config.nixpkgs.buildPlatform.system = "x86_64-linux";

    config.custom =
      {
        user.kieran = import ../../users/kieran {inherit pkgs config flake;};
      }
      // builtins.fromTOML (builtins.readFile ./config.toml);
  };
  # TODO: Implement the configuration of the server.
}
