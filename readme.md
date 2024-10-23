# Readme

This repository contains the NixOS configuration for my systems.

- [Readme](#readme)
  - [Documentation](#documentation)
    - [Repository Structure](#repository-structure)
    - [Hosts](#hosts)
  - [Essential Resources](#essential-resources)
  - [Todo List](#todo-list)
  - [Lessons Learned](#lessons-learned)
    - [Don't Use Wayland Yet](#dont-use-wayland-yet)
    - [Make Sure You Have a User](#make-sure-you-have-a-user)

## Documentation

Documentation for the repository is available at [docs/](docs/readme.md) and
details how to develop in the repository, and use systems configured with it.

### Repository Structure

- [docs](docs/readme.md) contains documentation generated during the build
  process.
- [hosts](hosts/) contains the configuration for each host.
- [media](media/) contains media used throughout the repository.
- [modules](modules/) modules included by the hosts.
  - [home](modules/home/) modules used by home-manager.
  - [nixos](modules/nixos/) modules used by NixOS.
- [packages](packages/) contains packages and scripts written for the
  repository.
- [shells](shells/) contains dev shells for use with `nix develop`.
- [users](users/) contains user configurations.
- [flake.nix](flake.nix) is the entry point for the repository.
- [treefmt.nix](treefmt.nix) configuration for Treefmt, a tool to unify
  formatters for all languages in a project.

### Hosts

The following hosts are configured in the repository. As I am a massive nerd,
they are named after ships from The Expanse.

- [rocinante](hosts/rocinante/configuration.nix) - My main desktop.<br> Primary
  system for just about any task. Fast, powerful, and has a lot of storage.
- [canterbury](hosts/canterbury/configuration.nix) - My laptop.<br> Portable,
  lightweight, good battery life, and fast enough for what it does.

## Essential Resources

The following resources were essential in setting up this repository and served
as frequent references. Other resources used are linked as-and-when they were
used.

- [Isaac Elliott's Blog on mkDerivation](https://blog.ielliott.io/nix-docs/mkDerivation.html) -
  A great explanation of `mkDerivation`.
- [Noogle](https://noogle.dev/) - A search engine for NixOS functions.
- [Vimjoyer](https://www.youtube.com/@vimjoyer) - A great resource for NixOS.
  Introduces many important concepts, tools, and all around was my go-to for
  learning NixOS.
- [Sphinx NixOS Manual](https://nlewo.github.io/nixos-manual-sphinx/development/option-types.xml.html) -
  The official NixOS manual in a format that doesn't freeze with 32GB of RAM.
- [Teu5us' Nix Library](https://teu5us.github.io/nix-lib.html) - Documentation
  for what the Nix library does and, more importantly, that the functions exist.

## Todo List

Tasks I want to complete in the future. I'm tracking these here rather than in
issues so I can do all my work in one place.

- ❎ Automate updates of packages. (Not planned)
- [x] Preview changes before applying them.
      [https://www.youtube.com/watch?v=DnA4xNTrrqY](https://www.youtube.com/watch?v=DnA4xNTrrqY)
- [x] Generate documentation rather than doing it manually
  - [x] For functions
  - [x] For options
- [x] Set keyboard shortcuts
  - [x] `Alt+T` to open terminal
  - [x] `Ctrl+Shift+Escape` to open System Monitor
  - [x] `Ctrl+Alt+E` to open FSearch
  - [x] Some way to disable keyboard LEDs
- [x] Associate file types with programs
  - [x] PDFs with Firefox, overriding LibreOffice
  - [x] Skyrim and Fallout 4 saves with ReSaver (already defined mime type, just
        need to set the program)
- ❎ Port my server to NixOS. (Raspberry Pi 5 is currently unsupported. Putting
  this on hold for now)
  - [x] Build ISO
        [https://www.youtube.com/watch?v=-G8mN6HJSZE](https://www.youtube.com/watch?v=-G8mN6HJSZE)
  - [ ] Remove anything not needed for a server
  - [ ] Update `rebuild update` as discussed in
        [Nix Server](./docs/plan/nix-server.md)
- [ ] Allow home-manager to be used independently of NixOS
  - [ ] Minimise usage of `hostConfig`, then pass it in as an argument (overlays
        should help with this)
  - [ ] Put this on the server until we can run full NixOS on it
- [ ] Automate running checks on the repo. Do these in nix's `checkPhase`?
  - [ ] Links in Markdown
  - [ ] Links in comments
        [extension](https://marketplace.visualstudio.com/items?itemName=Isotechnics.commentlinks)
- [ ] Pre-commit hooks
  - [ ] Check that `nix fmt` doesn't change anything
- [x] Convert to `flake-parts` for better modularity
  - [x] `flake.nix`
  - [x] Template
- [ ] Get swap files working

## Lessons Learned

Here are some mistakes I made and lessons learned while setting up this
repository.

### Don't Use Wayland Yet

Wayland is still quite buggy for me. I've had issues with flickering and Proton
games don't seem to work at all. Stick with X11 for now. Your choice will
persist between reboots.

Status June 2024: Wayland causes flickering in Skyrim when there's dropped
frames, which I think is due to double buffering. The issue occurs on both GNOME
Wayland and Hyprland. Stick with X11.

### Make Sure You Have a User

It's completely valid syntax to have a system without any usable users. Make
sure your config generates at least one and that they have a password set and
are in the `wheel` group to use `sudo`.

If you f\*\*ked up and can't log in, boot into a live NixOS environment and
mount both the root and boot partitions. Then, run `nixos-enter` to chroot into
the system. You can then fix the configuration and rebuild. If applying the
config fails, try setting your user's password anyway with `passwd <username>`
and rebooting into your main OS.
