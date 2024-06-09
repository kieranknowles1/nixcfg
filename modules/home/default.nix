# Importer for all the modules in this directory
# Modules can be enabled or disabled by giving them options in their own files
{ ... }:

{
  imports = [
    ./docs.nix
    ./edit-config
    ./espanso
    ./firefox.nix
    ./games.nix
    ./gnome.nix
    ./mime
    ./nushell
    ./shortcuts
    ./vscode
  ];
}
