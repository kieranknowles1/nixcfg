# Usage Information

- [Usage Information](#usage-information)
  - [Backups](#backups)
  - [Dev Shells](#dev-shells)
  - [Using in Another Flake](#using-in-another-flake)

## Backups

Backups can be configured per-host and are encrypted with a password, stored in
the host's `secrets.yaml` file, which is itself encrypted based on the user's
private SSH key. Backups run automatically on a daily basis, and run on boot if
the last backup was missed.

A wrapper script for each repository is provided on the `PATH` as
`restic-<repo>` and can be used the same as the regular `restic` command, but
with the repository and password pre-configured.

By default, daily backups are retained for 7 days, weekly backups for 4 weeks,
and monthly backups for 12 months. This can be overridden per-repository.

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
