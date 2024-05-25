# Readme

This repository contains the NixOS configuration for my desktop computer.

## Usage

To rebuild the system, run `./rebuild.sh <commit message>`.
This will update and switch to the current changes, then commit them if it was successful.

To update packages, run `nix flake update`. Most packages use the stable channel, but there
is a per-package override for some packages to use master instead.

## Options

The following options can be set in the `configuration.nix` file, all under the `custom` key.

- `games.enable` - Install game-related packages e.g., Steam. Should be `true` for any host used for gaming.
- `nvidia.enable` - Install Nvidia drivers. Should be `true` for any host with an Nvidia GPU.

To enable them in a host, add the following to the host's configuration:

```nix
# All the options I added are under the custom key
custom = {
  nvidia.enable = true; # Enable Nvidia drivers. Will not work unless the host has an Nvidia GPU.
  # Any other options go here
};
```

## Repository Structure

- [hosts](hosts/) contains the configuration for each host.
- [media](media/) contains media used throughout the repository.
  - [readme.md](media/readme.md) lists sources for media.
- [modules](modules/) modules included by the hosts.
  - [home](modules/home/) modules used by home-manager.
  - [nixos](modules/nixos/) modules used by NixOS.
- [users](users/) contains user configurations.
- [flake.nix](flake.nix) is the entry point for the repository.
- [rebuild.sh](rebuild.sh) script to update from the repository and commit changes.

## Todo List

Tasks I want to complete in the future. I'm tracking these here rather than in issues so
I can do all my work in one place.

- [ ] Automate updates of packages.
- [ ] Build an ISO with the configuration. [https://www.youtube.com/watch?v=-G8mN6HJSZE](https://www.youtube.com/watch?v=-G8mN6HJSZE)
- [ ] Preview changes before applying them. [https://www.youtube.com/watch?v=DnA4xNTrrqY](https://www.youtube.com/watch?v=DnA4xNTrrqY)

## Lessons Learned

Here are some mistakes I made and lessons learned while setting up this repository.

### Don't Use Wayland Yet

Wayland is still quite buggy for me. I've had issues with flickering and Proton games
don't seem to work at all. Stick with X11 for now. Your choice will persist between reboots.

### Make Sure You Have a User

It's completely valid syntax to have a system without any usable users. Make sure your config
generates at least one and that they have a password set and are in the `wheel` group to use
`sudo`.

If you f**ked up and can't log in, boot into a live NixOS environment and mount both the root
and boot partitions. Then, run `nixos-enter` to chroot into the system. You can then fix the
configuration and rebuild. If applying the config fails, try setting your user's password anyway
with `passwd <username>` and rebooting into your main OS.
