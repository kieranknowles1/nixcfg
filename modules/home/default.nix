# Importer for all the modules in this directory
# Modules can be enabled or disabled by giving them options in their own files
{...}: {
  imports = [
    ../shared

    ./aliases.nix
    ./common.nix
    ./desktop
    ./discord.nix
    ./docs.nix
    ./editor
    ./espanso
    ./firefox.nix
    ./games
    ./git
    ./llm.nix
    ./mime.nix
    ./mutable.nix
    ./portfolio.nix
    ./nushell
    ./office
    ./shortcuts
    ./theme.nix
    ./timer.nix
    ./trilium.nix
  ];
}
