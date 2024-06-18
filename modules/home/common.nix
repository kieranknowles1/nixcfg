# Options that are used in multiple modules
{
  config,
  lib,
  ...
}: {
  options = {
    custom.repoPath = lib.mkOption {
      description = "Path to the repository on disk, relative to the home directory";
      type = with lib.types; uniq str;
    };
  };

  config = {
    # Set the FLAKE environment variable for use in nixhelper and other scripts
    systemd.user.sessionVariables = {
      FLAKE = "${config.home.homeDirectory}/${config.custom.repoPath}";
    };
  };
}
