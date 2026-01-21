{
  runCommand,
  lib,
  self,
}:
/*
Fetch a filtered subset of the `assets` repository.

# Arguments
name :: String : Output derivation name

filter :: String -> Bool : Filter to select assets by file path

# Returns
The `nixcfg-assets` repository, filtered as requested. File paths
are not modified.

# Example
```
assetsDir {
  name = "wallpapers";
  # Fetch everything from `/wallpapers`
  filter = lib.hasPrefix "wallpapers/";
};
```
*/
{
  name,
  filter,
}: let
  linkFile = fileName: file: let
    dirname = builtins.dirOf fileName;
  in ''
    mkdir -p $out/${dirname}
    ln -s ${file} $out/${fileName}
  '';
  filteredFiles = lib.filterAttrs (k: _v: filter k) self.assets;
  flatFiles = lib.mapAttrsToList (name: file: linkFile name file) filteredFiles;
in
  runCommand name {} ''
    mkdir -p $out
    ${builtins.concatStringsSep "\n" flatFiles}
  ''
