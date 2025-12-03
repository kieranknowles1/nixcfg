# Development Information

Information on how to develop this repository. See also:
[modules](./modules/readme.md) for specific modules or
[nix library](../generated/lib.md) for extensions to the Nix library.

- [Development Information](#development-information)
  - [Assets](#assets)
  - [Building](#building)
  - [Dev Shells](#dev-shells)
  - [Using in Another Flake](#using-in-another-flake)
  - [Host Definition](#host-definition)
  - [User Definition](#user-definition)
  - [Documenting](#documenting)
  - [Debugging](#debugging)
  - [Useful Tools](#useful-tools)
    - [`nix-tree`](#nix-tree)
    - [`nix repl`](#nix-repl)

## Assets

Binary blobs, such as photos and videos, are stored in their own `nixcfg-assets`
repository to reduce their overhead on the main monorepo. Rather than using a
flake input, which would have to be downloaded in full for any change, these are
exposed as individual files under the `assets` flake output which are lazily
downloaded.

After pushing `nixcfg-assets`, run `sync-assets` to update the manifest so that
configurations can reference new versions.

## Building

A `rebuild` utility is provided for common build workflows, such as updating
packages or rebuilding then committing changes. The utility automatically
commits staged changes along with a diff of installed packages and their
versions.

It is advised to use `rebuild build` when adding new packages or editing a
host's `configuration.nix` to track which generation number the changes were
made in for easier rollbacks.

`rebuild update` should be run at least once every two weeks to keep inputs up
to date. NuShell will print a reminder if this is overdue. This builds and diffs
all hosts, not just the currently active one, to give a full picture of what
deployment will do. After an update, **do not** push changes until after a
reboot and ensure no obvious issues arise. After pushing, other hosts must be
manually updated.

## Dev Shells

Dev shells are provided for development of various languages/projects. These can
be entered with `devr <shell>`. A list of available shells can be found with
`nix flake show`.

## Using in Another Flake

This repository can be used as an input to another flake same as any other
flake, components can then be used as needed. A template for this is provided
and can be used with `nix flake init --template github:kieranknowles1/nixcfg`.
Be warned that breaking changes can and will be introduced here without warning,
so updating inputs may require changes to the consuming flake.

## Host Definition

Each host is defined as a subdirectory of the `hosts` directory and enables
parts of the flake as needed. While not required, it is recommended to only set
options under the `custom` key here to avoid code duplication between hosts.

See [hosts/rocinante](../../hosts/rocinante/) for an example host definition.

## User Definition

Similar to hosts, users are defined in the `users` directory and again should
only use the `custom` key. These should be functions imported by hosts and
returning the following:

```nix
# NixOS-side properties
core = {
  displayName = "John Smith";
  isSudoer = true;
  shell = pkgs.my-fancy-shell;

  authorisedKeys = [
    list of ssh keys
  ];
};

# Home Manager module
home = {
  imports = [ ./all-there-is-to-import.nix];
};
home.stateVersion = "read-the-manual";
```

See [users/kieran](../../users/kieran/default.nix) for an example user
definition.

## Debugging

The `confbuild` and `confeval` commands are provided as shorthands to build or
display a NixOS option. Derivations used internally can be exposed here as
options with `type = types.path`, as is done in
[home/docs/default.nix](../../modules/shared/docs.nix).

```nu
# Per-host. Can be converted to a Nushell table for easier reading.
confeval n custom.hardware | from json

# Per-user. Builds are linked to ./result
confbuild h docs-generate.build.generated
```

## Useful Tools

### Comma

Applications can be run without installing them using the `,` command, great for
when a command is needed one-off.

### `nix-tree`

`nix-tree` is a utility that visualises what derivations are included and what
depends on them. This is useful to find why a library is included when you
didn't expect it to be.

### `nix repl`

`nix repl` can load the current flake using `:lf .` and allows you to
interactively explore its outputs and test expressions. This is an alternative
to `confeval` that supports tab completion and the full Nix language.

```nix
# Load the flake from $PWD
:lf .

# Now you can access the flake's outputs
builtins.readFile (lib.docs.mkPackageDocs packages.x86_64-linux)
```
