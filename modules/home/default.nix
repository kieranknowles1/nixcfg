# Importer for all the modules in this directory
# Modules can be enabled or disabled by giving them options in their own files
{...}: {
  imports = [
    ./common.nix
    ./desktop
    ./discord.nix
    ./docs.nix
    ./editor
    ./espanso
    ./firefox.nix
    ./games
    ./ledstate.nix
    ./mime.nix
    ./mutable.nix
    ./nushell
    ./office
    ./shortcuts
    ./secrets.nix
    ./theme.nix
    ./trilium.nix
  ];
}
