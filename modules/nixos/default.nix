# Importer for all the modules in this directory
# Modules can be enabled or disabled by giving them options in their own files
{...}: {
  imports = [
    ../shared

    ./archiveteam.nix
    ./backup.nix
    ./compat.nix
    ./core.nix
    ./desktop
    ./docs.nix
    ./hardware.nix
    ./ledstate.nix
    ./llm.nix
    ./locale.nix
    ./mkdir.nix
    ./networking.nix
    ./printing.nix
    ./remotebuild.nix
    ./server
    ./ssh
    ./timer.nix
    ./topology.nix
    ./thunderbird.nix
    ./users.nix
    ./vr.nix
  ];
}
