# Readme

This repository contains the NixOS configuration for my systems.

- [Readme](#readme)
  - [Usage](#usage)
    - [System Usage](#system-usage)
      - [Key Bindings](#key-bindings)
  - [Documentation and Development Notes](#documentation-and-development-notes)
    - [Library](#library)
    - [Options](#options)
    - [Repository Structure](#repository-structure)
    - [Essential Resources](#essential-resources)
    - [Todo List](#todo-list)
  - [Lessons Learned](#lessons-learned)
    - [Don't Use Wayland Yet](#dont-use-wayland-yet)
    - [Make Sure You Have a User](#make-sure-you-have-a-user)

## Usage

To rebuild the system, run `./rebuild.py <commit message>`.
This will update and switch to the current changes, then commit them if it was successful.
For more information, run `./rebuild.py --help`.

### System Usage

#### Key Bindings

- `Alt+T` - Open terminal
- `Ctrl+Shift+Escape` - Open System Monitor
- `Ctrl+Alt+E` - Open FSearch

## Documentation and Development Notes

### Library

An extension to the standard nixpkgs library is provided in the `flake.lib` attribute set. Documentation is generated
during the build process and can be found in [docs/lib.md](docs/lib.md).

This is generated with [nixdoc](https://github.com/nix-community/nixdoc) and uses the [CommonMark](https://commonmark.org/)
flavour of Markdown.

### Options

Several options are available to customize the configuration on top of what the flake's inputs provide, although
it is preferred to only use the newly provided options in the `configuration.nix` file. All newly provided options
are under the `custom` key. This is generated during the build process. Host options are documented in [docs/host-options.md](docs/host-options.md)
while user-specific options are in [docs/user-options.md](docs/user-options.md). These can be used as any other NixOS option would be.

This is generated with `nixosOptionsDoc` and I wouldn't have known about it or how to use it without Brian McGee's
[blog post](https://bmcgee.ie/posts/2023/03/til-how-to-generate-nixos-module-docs/).

### Repository Structure

- [docs (gitignored)](docs/) contains documentation generated during the build process.
- [hosts](hosts/) contains the configuration for each host.
- [media](media/) contains media used throughout the repository.
- [modules](modules/) modules included by the hosts.
  - [home](modules/home/) modules used by home-manager.
  - [nixos](modules/nixos/) modules used by NixOS.
- [packages](packages/) contains packages and scripts written for the repository.
- [users](users/) contains user configurations.
- [export-blueprints.py](export-blueprints.py) script to export Factorio blueprints to the repository.
- [flake.nix](flake.nix) is the entry point for the repository.
- [rebuild.py](rebuild.py) script to update from the repository and commit changes.

### Essential Resources

The following resources were essential in setting up this repository and served as frequent references. Other resources
used are linked as-and-when they were used.

- [Isaac Elliott's Blog on mkDerivation](https://blog.ielliott.io/nix-docs/mkDerivation.html) - A great explanation of `mkDerivation`.
- [Noogle](https://noogle.dev/) - A search engine for NixOS functions.
- [Vimjoyer](https://www.youtube.com/@vimjoyer) - A great resource for NixOS. Introduces many important concepts, tools, and all around was my go-to for learning NixOS.
- [Sphinx NixOS Manual](https://nlewo.github.io/nixos-manual-sphinx/development/option-types.xml.html) - The official NixOS manual in a format that doesn't freeze with 32GB of RAM.

### Todo List

Tasks I want to complete in the future. I'm tracking these here rather than in issues so
I can do all my work in one place.

- ❎ Automate updates of packages. (Not planned)
- ❎ Build an ISO with the configuration. [https://www.youtube.com/watch?v=-G8mN6HJSZE](https://www.youtube.com/watch?v=-G8mN6HJSZE) (Not planned)
- [x] Preview changes before applying them. [https://www.youtube.com/watch?v=DnA4xNTrrqY](https://www.youtube.com/watch?v=DnA4xNTrrqY)
- [x] Generate documentation rather than doing it manually
  - [x] For functions
  - [x] For options
- [x] Set keyboard shortcuts
  - [ ] Run autokey on startup
  - [x] `Alt+T` to open terminal
  - [x] `Ctrl+Shift+Escape` to open System Monitor
  - [x] `Ctrl+Alt+E` to open FSearch
  - [ ] Some way to disable keyboard LEDs
- [x] Associate file types with programs
  - [x] PDFs with Firefox, overriding  LibreOffice
  - [x] Skyrim and Fallout 4 saves with ReSaver (already defined mime type, just need to set the program)
- [ ] Automate running checks on the repo. Do these in nix's `checkPhase`?
  - [ ] Links in Markdown
  - [ ] Links in comments [extension](https://marketplace.visualstudio.com/items?itemName=Isotechnics.commentlinks)

## Lessons Learned

Here are some mistakes I made and lessons learned while setting up this repository.

### Don't Use Wayland Yet

Wayland is still quite buggy for me. I've had issues with flickering and Proton games
don't seem to work at all. Stick with X11 for now. Your choice will persist between reboots.

Status June 2024: Wayland causes flickering in Skyrim when there's dropped frames, which I think
is due to double buffering. The issue occurs on both GNOME Wayland and Hyprland. Stick with X11.

### Make Sure You Have a User

It's completely valid syntax to have a system without any usable users. Make sure your config
generates at least one and that they have a password set and are in the `wheel` group to use
`sudo`.

If you f**ked up and can't log in, boot into a live NixOS environment and mount both the root
and boot partitions. Then, run `nixos-enter` to chroot into the system. You can then fix the
configuration and rebuild. If applying the config fails, try setting your user's password anyway
with `passwd <username>` and rebooting into your main OS.
