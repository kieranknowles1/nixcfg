# Importer for all the modules in this directory
# Modules can be enabled or disabled by giving them options in their own files
{...}: {
  imports = [
    ./core.nix
    ./desktop
    ./development.nix
    ./firefox.nix
    ./games.nix
    ./libraries.nix
    ./locale.nix
    ./networking.nix
    ./nvidia.nix
    ./office.nix
    ./printing.nix
    ./ssh
    ./theme.nix
    ./thunderbird.nix
  ];
}
