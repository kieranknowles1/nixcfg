# Options that are used in multiple modules
{
  lib,
  config,
  ...
}: {
  options = {
    custom.repoPath = lib.mkOption {
      description = "Path to the repository on disk, relative to the home directory";
      type = with lib.types; uniq str;
    };
  };

  config = {
    systemd.user.sessionVariables = {
      # NixHelper uses this to find the repository
      FLAKE = "${config.home.homeDirectory}/${config.custom.repoPath}";
    };
  };
}
