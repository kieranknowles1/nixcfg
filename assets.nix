{
  flake-parts-lib,
  lib,
  ...
}: {
  # External assets. Use `sync-assets` from nix-utils to update
  options.flake = let
    inherit (flake-parts-lib) mkSubmoduleOptions;
    inherit (lib) mkOption types;
  in
    mkSubmoduleOptions {
      assets = mkOption {
        type = types.lazyAttrsOf types.path;
        default = {};
        description = "External assets for the flake.";
      };
    };

  config.flake.assets = let
    manifest = builtins.fromJSON (builtins.readFile ./asset-manifest.json);
    owner = "kieranknowles1";
    repo = "nixcfg-assets";
    url = path: "https://raw.githubusercontent.com/${owner}/${repo}/${manifest.rev}/${path}";
  in
    lib.mapAttrs (path: hash:
      builtins.fetchurl {
        url = url path;
        sha256 = hash;
      })
    manifest.files;
}
