# Readme

This repository contains the NixOS configuration for my desktop computer.

## Repository Structure

- [hosts](hosts/) contains the configuration for each host.
- [media](media/) contains media used throughout the repository.
  - [readme.md](media/readme.md) lists sources for media.
- [modules](modules/) modules included by the hosts.
  - [home](modules/home/) modules used by home-manager.
  - [nixos](modules/nixos/) modules used by NixOS.
- [flake.nix](flake.nix) is the entry point for the repository.
- [rebuild.sh](rebuild.sh) script to update from the repository and commit changes.
