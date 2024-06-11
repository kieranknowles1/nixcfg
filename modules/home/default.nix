# Importer for all the modules in this directory
# Modules can be enabled or disabled by giving them options in their own files
{
  inputs,
  ...
}:

{
  imports = [
    # TODO: Find a better place for this
    # inputs.ags.homeManagerModules.default
    ./docs.nix
    ./edit-config
    ./espanso
    ./firefox.nix
    ./games.nix
    ./gnome.nix
    ./hyprland.nix
    ./mime
    ./nushell
    ./shortcuts
    ./vscode
  ];
}
