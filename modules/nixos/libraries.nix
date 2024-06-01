# Installs libraries needed by unpackaged executables, and enables nix-ld
{ pkgs, ... }:
{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libz
    ];
  };
}
