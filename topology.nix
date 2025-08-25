{
  pkgs,
  inputs,
  self,
}:
import inputs.nix-topology {
  inherit pkgs;

  modules = pkgs.lib.singleton {
    nodes =
      builtins.mapAttrs (name: _config: {
        inherit name;
        deviceType = "device";
      })
      self.nixosConfigurations;
  };
}
