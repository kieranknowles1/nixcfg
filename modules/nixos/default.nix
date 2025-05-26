# Importer for all the modules in this directory
# Modules can be enabled or disabled by giving them options in their own files
{...}: {
  imports = [
    ../shared

    ./backup.nix
    ./core.nix
    ./desktop
    ./ledstate.nix
    ./llm.nix
    ./locale.nix
    ./networking.nix
    ./nvidia.nix
    ./printing.nix
    ./ssh
    ./theme.nix
    ./thunderbird.nix
    ./users.nix
    ./vr.nix
  ];
}
