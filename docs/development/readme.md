# Development Information

Information on how to develop this repository.

- [Development Information](#development-information)
  - [Building](#building)
    - [Packages](#packages)
  - [Host Definition](#host-definition)
  - [User Definition](#user-definition)
  - [Documenting](#documenting)
  - [Debugging](#debugging)
  - [Useful Tools](#useful-tools)
    - [`nix-tree`](#nix-tree)
    - [`nix repl`](#nix-repl)

## Building

A `rebuild` utility is provided for common build workflows, such as updating
packages or rebuilding then committing changes. Use `run rebuild` while in the
flake's directory to run this utility. Building and updating automatically
commit changes including a diff of installed packages/versions in their
messages.

It is advised to use `rebuild build` when adding new packages or editing
`config.toml` in order to track NixOS's generation number and when dependencies
were introduced.

`rebuild update` should be run at least once every two weeks to keep inputs up
to date. NuShell will print a reminder if this is overdue. After an update, **do
not** push changes until after a reboot to ensure that drivers were not broken.

For more information, run `rebuild --help`.

### Packages

When updating hashes for packages, replace the old hash with an empty string
first to force a download, otherwise Nix will see the old hash and treat it as
pointing to the cached download.

<!-- TODO: Can this be automated? Not sure if this statement is even accurate -->

## Host Definition

Each host is defined as a subdirectory of the `hosts` directory and enables
parts of the flake as needed. Only the `custom` key should be used in the host's
configuration to avoid any code duplication. I am aware that this makes the host
definitions tightly coupled to the flake, but believe this to be a worthwhile
trade-off to limit the amount of code used to define a host, moving it to a
central modules folder instead.

JSON schemas are generated for the flake's options, found in
[generated/host-options.schema.json](../generated/host-options.schema.json). A
TOML language server can be pointed at this file to provide immediate feedback
on options.

See [hosts/rocinante](../../hosts/rocinante/) for an example host definition.

## User Definition

Similar to hosts, users are defined in the `users` directory and again should
only use the `custom` key. However, instead of being a plain Attribute Set, a
user is a function taking in nixpkgs and the host's config, and returning an
Attribute Set following the format described in
[custom.user](../generated/host-options.md#customuser).

While JSON schemas are also available at
[generated/user-options.schema.json](../generated/user-options.schema.json),
these are not as useful as in hosts as users may need different configurations
for different hosts, something impossible to represent in TOML without a lot of
additional complexity.

See [users/kieran](../../users/kieran/default.nix) for an example user
definition.

## Documenting

Documentation should be generated wherever possible, as this makes them tightly
coupled to their code and more likely to be up-to-date.

For more general information, such as this document, Markdown in the `docs`
directory is used.

Graphs may be generated using `graphviz` and `dot`, these are automatically
converted to SVGs by buildStaticSite. While Mermaid is natively supported by
GitHub, it is much less effective at preventing overlap and therefore unsuitable
for my needs.

## Debugging

The `confbuild` and `confeval` commands are provided to build/display the value
of a config path. To make a derivation debuggable, expose it as an option with
`type = types.path` and set it to a derivation as is done in
[docs.nix](../../modules/home/docs.nix).

```nu
# Per-host. Can be converted to a Nushell table for easier reading.
confeval n features | from json

# Per-user. Builds are linked to ./result
confbuild h docs-generate.build.generated
```

## Useful Tools

### `nix-tree`

The `nix-tree` utility can be useful for visualizing what derivations are
included and why. This is not included in any configuration/shell, but can be
run with `nix run nixpkgs#nix-tree`. This can be useful to find why a package is
included when you didn't expect it to be.

### `nix repl`

The `:lf` command in `nix repl` can be used to load a flake's outputs into the
repl, allowing you to interactively explore its outputs and test out functions.
For example:

```nix
# Load the flake from $PWD
:lf .

# Now you can access the flake's outputs
builtins.readFile (lib.docs.mkPackageDocs packages.x86_64-linux)
```
