# Importer for all the modules in this directory
{ ... }:
{
  imports = [
    ./firefox.nix
    ./gnome.nix
    ./locale.nix
    ./nvidia.nix
    ./theme.nix
    ./thunderbird.nix
  ];
}
