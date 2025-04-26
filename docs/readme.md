# Repository Documentation

![Inputs of the flake, excluding the standard `nixpkgs` and `systems`.](./generated/flake-tree.svg)

- [Generated](./generated/readme.md)<br> Wherever possible, documentation is
  generated from the repository itself rather than being written manually. This
  avoids duplication, puts the documentation closer to the code, and ensures
  that it is up-to-date.

  Note that generated docs only include details that are enabled on the host.
  For example, the `Alt+Shift+S` keybinding is only used for hosts with
  `custom.games.enabled` set to `true` as it is only enabled if the `games`
  module is active.

- [Development](./development/readme.md)<br> Information on how to develop this
  repository.
  - [Style Guide](./development/style-guide.md)<br> Guidelines for code and
    documentation.
- [Usage](./usage/readme.md)<br> How to use systems configured with this
  repository.
  - [Troubleshooting](./usage/troubleshooting.md)<br> Particularly odd issues
    that have been encountered and how to resolve them.
- [Planning](./plan/readme.md)<br> Planning documents for past, present, and
  future development.
