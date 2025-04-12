# Activate Mutable Planning

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

// impl note: The config format was changed to be the same as Nix
config: Map<string, ConfigEntry>
interface ConfigEntry {
    // destination: string // Use the map key instead
    source: string
    on_conflict: 'replace' | 'warn'
}
```

Link previous config file after activation for future reference. If previous is
not found, treat as if it was an empty file. Store in
`~/.config/activate-mutable-config.json`.

![Activate Mutable Flowchart](./activate-mutable-flowchart.svg)

3 possible outcomes, use an enum to represent them.

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

Apply the usual rules on a per-file basis recursively. Still don't allow any
symlinks.

## V4 - Custom Comparison

Add a CompareScript to ConfigEntry. If set, run script with old and new as
arguments.

If script exits 0, files match. Anything else and they differ. Use in place of
hash comparison.

Use for OpenMW Lua data and more volatile ini files.

Pull could use a similar script to discard/modify the file before copying to
repo, such as excluding some sections of an ini file.

### Detailed Plan

New field in config: `transformer: Option<String>`. If `None`, no transform is
applied.

If `Some`, it is a path to a script with the signature: `transform [in-file]`.
This script takes the **deployed file** as input, and outputs a file, **repo
file**, that is suitable for version control(e.g., converting binary data to
text), on stdout.

**Repo file** is converted to **deployed file** during the NixOS build process.

**deployed file** is considered equal to **repo file** if `transform` outputs
the same as **repo file's** contents.
