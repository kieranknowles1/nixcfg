# Importer for all the modules in this directory
# Modules can be enabled or disabled by giving them options in their own files
{...}: {
  imports = [
    ../shared

    ./common.nix
    ./desktop
    ./discord.nix
    ./docs.nix
    ./editor
    ./espanso
    ./firefox.nix
    ./games
    ./git
    ./ledstate.nix
    ./llm.nix
    ./mime.nix
    ./mutable.nix
    ./nushell
    ./office
    ./shortcuts
    ./theme.nix
    ./trilium.nix
  ];
}
