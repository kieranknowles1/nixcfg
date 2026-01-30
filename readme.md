# Readme

This repository contains the NixOS configuration for my systems. Feel free to
use it as a reference or inspiration. I make no guarantees about stability:
breaking changes can and will be made at any time for any reason. Manual
migration steps are not documented.

- [Readme](#readme)
  - [Documentation](#documentation)
    - [Repository Structure](#repository-structure)
    - [Hosts](#hosts)
  - [Essential Resources](#essential-resources)
  - [Licensing](#licensing)

## Documentation

Documentation for the repository is available at [docs/](docs/readme.md) and
details how to develop in the repository, and use systems configured with it.

### Repository Structure

- [builders](builders/) Helpers to build packages or transform files. Think of
  it as `pkgs.stdenv` for `lib`.
- [cloud](cloud/) Cloud infrastructure as code declared using OpenTofu.
- [docs](docs/readme.md) - Documentation generated during the build process.
- [hosts](hosts/) - Configuration for each host.
- [modules](modules/) - Modules included by the hosts.
  - [home](modules/home/) - Modules for home-manager.
  - [nixos](modules/nixos/) - Modules for NixOS.
  - [shared](modules/shared/) - Modules common between home-manager and NixOS.
- [packages](packages/) - Packages and scripts written for the repository.
- [overlays](overlays/) - Overrides to nixpkgs and namespaces for external
  flakes.
- [shells](shells/) - Dev shells for use with `nix develop`.
- [users](users/) - User configurations.
- [flake.nix](flake.nix) - The entry point for the repository.
- [treefmt.nix](treefmt.nix) - Configuration for Treefmt, which unifies
  formatters for all languages I use.

### Hosts

The following hosts are configured in the repository. As I am a massive nerd,
they are named after ships from The Expanse.

- [canterbury](hosts/canterbury/configuration.nix) - My laptop.<br> Portable,
  lightweight, fast enough for what it does, and incredible battery life thanks
  to lacking ~~bloatware~~ Windows.
- [rocinante](hosts/rocinante/configuration.nix) - My main desktop.<br> Primary
  system for just about any task. Fast, powerful, and has a lot of storage.
- [tycho](hosts/tycho/configuration.nix) - My server.<br> Used to host a variety
  of services. Despite the name, it is not a build server. _VERY WORK IN
  PROGRESS_

## Why NixOS

Why use NixOS over other Linux distributions?

I started out with Ubuntu, and my first action was to setup a dotfiles repo to
store configs and automate setting up a new system. I'd encourage doing the same
for non-NixOS systems, at least as a learning experience.

When I discovered NixOS via
[No Boilerplate's Video](https://youtu.be/CwfKlX3rA6E), I immediately knew that
it was the solution I was looking for, performing most of what I was already
handling myself, but better in most cases. For example, rollback support saved
me after a bad driver update, which broke anything running OpenGL.

### The Bad Parts

While I find NixOS great, it isn't without its flaws, which are included here
along with some of the solutions I've found:

- Steep learning curve involving a domain specific language.
- Limited support for unpatched binaries<br>Wrap these with `steam-run` and hope
  for the best. I still haven't gotten things 100%.
- Bad documentation<br>Don't even bother with the HTML documentation, it
  struggles even with 32GB of RAM. Instead use one of the various sites listed
  in [Essential Resources](#essential-resources)
- Home files are read-only symlinks<br>Files deployed with home-manager are
  read-only symlinks to the actual files, which makes editing them from within
  applications difficult. I created my `activate-mutable` module to handle this
  using normal files. While it was good practice for Rust, I'd prefer if
  NixOS/home-manager supported it natively.
- No incremental package builds<br>While it's nice to be deterministic, it's not
  so fun when you have to rebuild the kernel or a package fails to link.

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

## Licensing

This repository and all its contents are available under the
[MIT License](./license.txt). However, certain packages are under different
licenses. This is documented under in individual `meta` attributes.
