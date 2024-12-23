# Development Information

- [Development Information](#development-information)
  - [Building](#building)
    - [Packages](#packages)
  - [Host Definition](#host-definition)
  - [User Definition](#user-definition)
  - [Documenting](#documenting)
  - [Best Practices](#best-practices)
    - [Error Handling](#error-handling)
    - [Code Style](#code-style)
  - [Debugging](#debugging)
  - [Useful Tools](#useful-tools)
    - [`nix-tree`](#nix-tree)
    - [`nix repl`](#nix-repl)

## Building

A `rebuild` utility is provided for common build workflows, such as updating
packages or rebuilding then committing changes. This is enabled in the `default`
[Dev Shell](usage.md#dev-shells).

For more information, run `rebuild --help`.

### Packages

When updating hashes for packages, replace the old hash with an empty string
first to force a download, otherwise Nix will see the old hash and treat it as
pointing to the cached download.

<!-- TODO: Can this be automated? -->

## Host Definition

Each host is defined as a subdirectory of the `hosts` directory and enables
parts of the flake as needed. Only the `custom` key should be used in the host's
configuration to avoid any code duplication. I am aware that this makes the host
definitions tightly coupled to the flake, but believe this to be a worthwhile
trade-off to limit the amount of code used to define a host, moving it to a
central modules folder instead.

JSON schemas are generated for the flake's options, found in
[generated/host-options.schema.json](./generated/host-options.schema.json). A
TOML language server can be pointed at this file to provide immediate feedback
on options.

See [hosts/rocinante](../hosts/rocinante/) for an example host definition.

## User Definition

Similar to hosts, users are defined in the `users` directory and again should
only use the `custom` key. However, instead of being a plain Attribute Set, a
user is a function taking in nixpkgs and the host's config, and returning an
Attribute Set following the format described in
[custom.user](./generated/host-options.md#customuser).

While JSON schemas are also available at
[generated/user-options.schema.json](./generated/user-options.schema.json),
these are not as useful as in hosts as users may need different configurations
for different hosts, something impossible to represent in TOML without a lot of
additional complexity.

See [users/kieran](../users/kieran/default.nix) for an example user definition.

## Documenting

Documentation should be generated wherever possible, as this makes them tightly
coupled to their code and more likely to be up-to-date.

For more general information, such as this document, Markdown in the `docs`
directory is used.

Graphs may be generated using `graphviz` and `dot`, then converted to SVG with
`run generate-graphs` for use as images in Markdown. While Mermaid is natively
supported by GitHub, it is much less effective at preventing overlap and
therefore unsuitable for my needs.

`generate-graphs --check` will raise an error if any files would have been
changed, intended to be used in CI to ensure that all graphs are up-to-date.

<!-- TODO: Can we check for outdated svg files? Dot complains about fontconfig
during a nix build -->

## Best Practices

The following practices are recommended when developing this repository:

### Error Handling

Use the `config.assertions` list to check for invalid options or combinations of
options, such as
[installing VS Code on a headless server](../modules/home/editor/vscode/default.nix).

This gives a nicely formatted error message and collects all errors rather than
stopping at the first one.

### Code Style

Since I plan this to be a long-term project and always work-in-progress, I want
to keep the codebase clean and easy to work with. The most important rule is:
**keep it simple**. If you can't understand what a piece of code does after a
few seconds, it's too complex. In addition:

Run `nix fmt` before committing to ensure consistent code style. This is also
configured to run a set of static analysers on their strictest settings. If a
static analyser says something is wrong, it's probably wrong.

An apostrophe (`'`) after a variable name is used to indicate that it is an
overridden package (See the
[reddit question](https://www.reddit.com/r/NixOS/comments/ttaw5u/what_is_the_purpose_of_single_quotes_after/),
TL;DR: it's from the prime symbol meaning a derivative in mathematics). This is
not strictly required, but is included for consistency with Nixpkgs.

## Debugging

To debug a derivation generated during a build, use `nix build`. This accepts a
path to any flake attribute, including the configs of hosts and users. To make a
derivation easily debuggable, declare an option with `type = types.path` and set
it to the path of the derivation, as is done in
[docs.nix](../modules/home/docs.nix).

The `confbuild` utility is provided to make this easier. Simply run the
following for any config path under `custom`:

```sh
# TODO: Expand this to a more general confeval that, depending on the
# type, will either build or evaluate the config. Should output as a Nushell
# table.
# Per-host
confbuild n <config-path>

# Per-user
confbuild u <config-path>
```

For example, to debug the aforementioned `docs` derivation, run:

```sh
confbuild n docs-generate.build.generated
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
