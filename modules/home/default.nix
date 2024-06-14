# Importer for all the modules in this directory
# Modules can be enabled or disabled by giving them options in their own files
{
  inputs,
  ...
}:

{
  imports = [
    ./common.nix
    ./docs.nix
    ./edit-config
    ./espanso
    ./firefox.nix
    ./games.nix
    ./hyprland
    ./mime
    ./nushell
    ./shortcuts
    ./vscode
  ];
}
