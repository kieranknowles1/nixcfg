# Development Information

## Building

A `rebuild` utility is provided for common build workflows, such as updating packages or rebuilding then
committing changes. This is enabled in the `default` [Dev Shell](usage.md#dev-shells).

For more information, run `rebuild --help`.

## Dependencies

The `nix-tree` utility can be useful for visualizing what derivations are included and why. This is
not included in any configuration/shell, but can be run with `nix run nixpkgs#nix-tree`. This can
be useful to find why a package is included when you didn't expect it to be.

## Host Definition

Each host is defined as a subdirectory of the `hosts` directory and enables parts of the flake as
needed. Only the `custom` key should be used in the host's configuration to avoid any code duplication.
I am aware that this makes the host definitions tightly coupled to the flake, but believe this to be
a worthwhile trade-off to limit the amount of code used to define a host, moving it to a central modules
folder instead.

JSON schemas are generated for the flake's options, found in [generated/host-options.schema.json](generated/host-options.schema.json). A TOML language server can be pointed at this file to provide immediate feedback on options.

See [hosts/desktop](../hosts/desktop/) for an example host definition.

## User Definition

Similar to hosts, users are defined in the `users` directory and again should only use the `custom` key.
However, instead of being a plain Attribute Set, a user is a function taking in nixpkgs and the host's
config, and returning an Attribute Set following the format described in
[custom.user](generated/host-options.md#customuser).

While JSON schemas are also available at
[generated/user-options.schema.json](generated/user-options.schema.json), these are not as useful as in
hosts as users may need different configurations for different hosts, something impossible to represent
in TOML without a lot of additional complexity.

See [users/kieran](../users/kieran/default.nix) for an example user definition.

## Best Practices

The following practices are recommended when developing this repository:

### Error Handling

Use the `config.assertions` list to check for invalid options or combinations of options, such as
[installing VS Code on a headless server](../modules/home/editor/vscode/default.nix).

This gives a nicely formatted error message and collects all errors rather than stopping at the first one.
