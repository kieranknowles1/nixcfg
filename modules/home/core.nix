{ flake, ... }:
{
  # Generate documentation for my custom library code
  # TODO: Thinkg of a better name for this module
  # TODO: Don't hardcode the path to the flake, maybe use an environment variable?
  home.file."Documents/src/nixcfg/documentation.md".source = flake.lib.docs.mkDocs ../../lib;
}
