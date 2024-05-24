# Importer for all the modules in this directory
# Modules can be enabled or disabled by giving them options in their own files
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
