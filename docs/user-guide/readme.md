# User Guide

How to use systems configured with this repository.

- [Usage Information](#usage-information)
  - [Backups](#backups)
  - [Mutable Files](#mutable-files)

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

## Mutable Files

Files can be deployed to the user's home directory in a mutable way using the
`config.mutable.file` home-manager option. This is useful for files that should
be modifiable after deployment, such as configuration files for applications.
Directories are also supported simply by pointing to one, and are useful for
multi-file configuration such as editor snippets.

The `activate-mutable` script is used to manage these files, and is configured
on a per-file basis to either replace when there are local changes, or to raise
a warning.

The `repo` subcommand is provided to pull changes in `$HOME` back into the flake
repository, where they can be used for future deployments.

The `info` subcommand can be used to list all mutable files, where they came
from in the flake, and how they handle local changes.

```sh
$ activate-mutable info

# example output
# /home/user/some-file:
#   Repository: modules/some-file
#   On conflict: Warn
```

## Fuzzy Search

The `telly` home-manager module provides fuzzy find utilities based on
[Television](https://github.com/alexpasmantier/television). The following
`commands` and **shortcuts** are available:

- **Ctrl+t**: Find file for prompt
- **Ctrl+r**: Search history
- `tvg`: Find and CD into git repository
- `tvf`: Open a file, by its name
- `tvc`: Open a file, by its contents
