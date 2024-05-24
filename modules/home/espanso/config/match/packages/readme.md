# Espanso Packages

The subdirectories of this contains packages installed via `espanso package install`. The
package contents are tracked by Git, rather than the package manager itself to follow Nix's
principle of determinism and to allow for modifications as needed.

## Modifications Made

- [contractions-en](contractions-en/package.yml): Use "'" (U+0027 Apostrophe) instead of "’" (U+2019 Right Single Quotation Mark)
- [accented-words](accented-words/package.yml):
  - Do not replace "role" with the French "rôle"
