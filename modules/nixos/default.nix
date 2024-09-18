# Importer for all the modules in this directory
# Modules can be enabled or disabled by giving them options in their own files
{...}: {
  imports = [
    ./backup.nix
    ./core.nix
    ./desktop
    ./development.nix
    ./games.nix
    ./ledstate.nix
    ./libraries.nix
    ./locale.nix
    ./networking.nix
    ./nvidia.nix
    ./office.nix
    ./printing.nix
    ./ssh
    ./secrets.nix
    ./theme.nix
    ./thunderbird.nix
    ./users.nix
  ];
}
