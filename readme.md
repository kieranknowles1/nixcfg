# Readme

This repository contains the NixOS configuration for my desktop computer.

## Usage

To rebuild the system, run `./rebuild.sh <commit message>`.
This will update and switch to the current changes, then commit them if it was successful.

To update packages, run `nix flake update`. Most packages use the stable channel, but there
is a per-package override for some packages to use master instead.

## Repository Structure

- [hosts](hosts/) contains the configuration for each host.
- [media](media/) contains media used throughout the repository.
  - [readme.md](media/readme.md) lists sources for media.
- [modules](modules/) modules included by the hosts.
  - [home](modules/home/) modules used by home-manager.
  - [nixos](modules/nixos/) modules used by NixOS.
- [flake.nix](flake.nix) is the entry point for the repository.
- [rebuild.sh](rebuild.sh) script to update from the repository and commit changes.
