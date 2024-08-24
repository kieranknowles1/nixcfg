# Provision secrets using SOPS
# These will be available in the `/run/secrets` directory and owned by root
{
  inputs,
  ...
}: {
  imports = [
    ../shared/secrets.nix
  ];

  config = {
    home-manager.sharedModules = [
      inputs.sops-nix.homeManagerModules.sops
    ];
  };
}
