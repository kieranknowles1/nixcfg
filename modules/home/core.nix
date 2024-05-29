{ flake, ... }:
{
  # Generate documentation for my custom library code
  # TODO: Thinkg of a better name for this module
  # TODO: Don't hardcode the path to the flake, maybe use an environment variable?
  home.file."Documents/src/nixcfg/docs/lib.md".source = flake.lib.docs.mkFunctionDocs ../../lib;
  home.file."Documents/src/nixcfg/docs/options.md".source = flake.lib.docs.mkOptionDocs ../nixos/default.nix;
}
