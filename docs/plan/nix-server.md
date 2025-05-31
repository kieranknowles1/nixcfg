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
