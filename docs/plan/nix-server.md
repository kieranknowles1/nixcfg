# NixOS Server Port (Raspberry Pi 5 8GB)

Port server to NixOS. Want to allow unattended updates, pull latest version
regularly (`rebuild pull` can do this, need to run it without a sudo prompt).

Want to hold some packages back, like `immich` in case of breaking changes. Can
probably do this in pure Nix by failing the build if the major version changes,
then manually migrating.

Currently, updating inputs only creates a diff for the current host and excludes
packages only used on other hosts. Additionally, Nix builds have a high memory
requirement, running on my 8GB laptop with Firefox open will freeze the system.
May be able to help this with a swap file, the installer failed to create one
for me.

Both issues could be fixed by building all targets during `rebuild update` on my
main PC, then pushing to a server that other hosts pull from. Commit messages
could then merge the diffs to show every package that was updated.

Try [nixos-hardware](https://github.com/NixOS/nixos-hardware)' RPI5 module.

## Service Identification

While I have quite a few services defined in my existing
[selfhosting](https://github.com/kieranknowles1/selfhosting) repo, I rarely use
most of them. Following is a list that I would like for a first iteration:

- [ ] Backups
- [x] Portfolio
- [ ] Dashboard
- [ ] Immich
- [ ] Trilium
- [ ] Paperless NGX
- [ ] Git
  - [ ] Back up my GitHub repos
- [x] Documentation

## Known Issues

This configuration is still **heavily** work in progress, and issues are to be
expected including (listed here as a checklist to be fixed). Please ignore how
I'm just blaming other people for all of these :).

- [ ] Locked to nixos-25.05 rather than nixos-unstable. Requires
      [nixpkgs#398456](https://github.com/NixOS/nixpkgs/pull/398456) to be
      merged.
- [ ] Difftastic fails with `<jemalloc>: Unsupported system page size`. Possible
      upstream issue.
- [ ] Comma fails with `nix-locate failed`.
      [Definite upstream issue](https://github.com/nix-community/comma/pull/103)
      and already fixed on nixpkgs-unstable.
