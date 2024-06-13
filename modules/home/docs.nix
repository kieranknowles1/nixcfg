# Module to include generated documentation for the flake and its options
{ flake, config, ... }: let
  repoPath = config.custom.repoPath;
in {
  config = {
    home.file."${repoPath}/docs/lib.md".source = flake.lib.docs.mkFunctionDocs ../../lib;
    home.file."${repoPath}/docs/host-options.md".source = flake.lib.docs.mkOptionDocs ../nixos/default.nix;
    home.file."${repoPath}/docs/user-options.md".source = flake.lib.docs.mkOptionDocs ./default.nix;
  };
}
