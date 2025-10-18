# Activate Mutable Planning

- [Activate Mutable Planning](#activate-mutable-planning)
  - [V1 - Minimum Viable Product](#v1---minimum-viable-product)
  - [V2 - Restore Changes to the Repo](#v2---restore-changes-to-the-repo)
  - [V3 - Handle Directories](#v3---handle-directories)
  - [V4 - Custom Comparison](#v4---custom-comparison)
    - [Detailed Plan - Transformer Model](#detailed-plan---transformer-model)

## V1 - Minimum Viable Product

```sh
activate-mutable activate [config-file] [home-directory]
```

Copy files to home so that they can be modified after NixOS activation. Don't
support directories yet, mvp is just to support files. Symlinks are immutable,
so they should not be allowed.

Config (JSON)

```ts
config: ConfigEntry[]

interface ConfigEntry {
    destination: string // Relative to home
    source: string // Absolute
    onConflict: 'replace' | 'warn'
}
```

````admonish note
This was implemented differently to match the Nix options structure.
```ts
config: Map<string, ConfigEntry>
interface ConfigEntry {
    destination: string // Use the map key instead, still relative to home
    source: string
    onConflict: 'replace' | 'warn'
}
```
````

Link previous config file after activation for future reference. If previous is
not found, treat as if it was an empty file. Store in
`~/.config/activate-mutable-config.json`.

![Activate Mutable Flowchart](./activate-mutable-flowchart.svg) The flowchart
depicts the following potential states of a file, and the actions taken based on
them.

States:

- Home identical to previous generation `EqualOld`
- Home identical to current generation `EqualNew`
- Home differs from both generations `Conflict`
- File not in home directory `NotInHome`

Actions:

- Do nothing - `EqualNew`
- Copy from source to destination -
  `NotInHome OR EqualOld OR (Conflict AND ReplaceOnConflict)`
- Log warning - `Conflict AND NOT ReplaceOnConflict`

## V2 - Restore Changes to the Repo

```sh
activate-mutable torepo [repo=$FLAKE] [home-directory=$HOME]
```

Copy currently deployed files back to the repository in order to transfer
changes. Take default arguments from the environment.

How to find the repo path? Make it an option, guess from store path, or
calculate the path using Nix. Automatic would be more convenient.

If the file needs preprocessing by Nix, what then? _Don't support this, code
settings were easy enough to migrate_

Current uses:

- [x] XDG template files
- [x] VSCode config (preprocessed, put deps on `$PATH` instead?)
- [x] VSCode bindings
- [x] Espanso config (needs directory support)
- [ ] Game config (still in old dotfiles repo)
- [x] VSCode snippets (needs directory support)

## V3 - Handle Directories

```admonish note
This ended up being implemented after [Custom Comparison](#v4---custom-comparison)
in v3.1.0
```

Apply the usual rules on a per-file basis recursively. Still don't allow any
symlinks.

### Detailed Plan - Recursion

If config entry points to a directory:

1. Walk directory (store when deploying, home when restoring)
2. Generate new entries based on contents
3. Recurse into subdirectories

## V4 - Custom Comparison

```admonish note
This ended up being implemented before [Handle Directories](#v3---handle-directories)
in v3.0.0
```

Add a CompareScript to ConfigEntry. If set, run script with old and new as
arguments.

If script exits 0, files match. Anything else and they differ. Use in place of
hash comparison.

Use for OpenMW Lua data and more volatile ini files.

Pull could use a similar script to discard/modify the file before copying to
repo, such as excluding some sections of an ini file.

### Detailed Plan - Transformer Model

New field in config: `transformer: Option<String>`. If `None`, no transform is
applied.

If `Some`, it is a path to a script with the signature: `transform [in-file]`.
This script takes the **deployed file** as input, and outputs a file, **repo
file**, that is suitable for version control(e.g., converting binary data to
text), on stdout.

**Repo file** is converted to **deployed file** during the NixOS build process.

**deployed file** is considered equal to **repo file** if `transform` outputs
the same as **repo file's** contents.
