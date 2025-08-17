# Importer for all the modules in this directory
# Modules can be enabled or disabled by giving them options in their own files
{...}: {
  imports = [
    ../shared

    ./backup.nix
    ./compat.nix
    ./core.nix
    ./desktop
    ./docs.nix
    ./hardware.nix
    ./ledstate.nix
    ./llm.nix
    ./locale.nix
    ./networking.nix
    ./printing.nix
    ./server
    ./ssh
    ./theme.nix
    ./timer.nix
    ./thunderbird.nix
    ./users.nix
    ./vr.nix
  ];
}
