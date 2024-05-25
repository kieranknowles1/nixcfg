# Importer for all the modules in this directory
# Modules can be enabled or disabled by giving them options in their own files
{ ... }:
{
  imports = [
    ./core.nix
    ./firefox.nix
    ./games.nix
    ./gnome.nix
    ./locale.nix
    ./nvidia.nix
    ./office.nix
    ./theme.nix
    ./thunderbird.nix
  ];
}
