{
  # TODO: Should be ARM for Raspberry Pi
  system = "x86_64-linux";

  config = {
    pkgs,
    config,
    self,
    ...
  }: {
    imports = [
      ./hardware-configuration.nix
    ];

    config.custom = self.lib.attrset.deepMergeSets [
      {
        user.kieran = import ../../users/kieran {inherit pkgs config self;};

        # TODO: Secrets
      }
      (builtins.fromTOML (builtins.readFile ./config.toml))
    ];
  };
}
