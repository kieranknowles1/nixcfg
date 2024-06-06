# Module to include generated documentation for the flake and its options
{ flake, lib, config, ... }: let
  repoPath = config.custom.repoPath;
in {
  options = {
    custom.repoPath = lib.mkOption {
      description = "Path to the repository on disk, relative to the home directory";
      type = with lib.types; uniq str;
      default = "Documents/src/nixcfg";
    };
  };

  config = {
    home.file."${repoPath}/docs/lib.md".source = flake.lib.docs.mkFunctionDocs ../../lib;
    home.file."${repoPath}/docs/host-options.md".source = flake.lib.docs.mkOptionDocs ../nixos/default.nix;
    home.file."${repoPath}/docs/user-options.md".source = flake.lib.docs.mkOptionDocs ./default.nix;
  };
}
