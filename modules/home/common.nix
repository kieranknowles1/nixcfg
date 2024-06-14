# Options that are used in multiple modules
{
  lib,
  ...
}: {
  options = {
    custom.repoPath = lib.mkOption {
      description = "Path to the repository on disk, relative to the home directory";
      type = with lib.types; uniq str;
    };
  };
}
