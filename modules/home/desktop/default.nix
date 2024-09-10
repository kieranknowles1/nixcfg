{
  lib,
  config,
  hostConfig,
  ...
}: let
  isDesktop = hostConfig.custom.deviceType == "desktop";
in {
  imports = [
    ./gnome.nix
  ];

  config = lib.mkIf isDesktop {
    # Add templates for creating new files
    # When creating from a template, the file will be copied from ~/Templates to the current directory
    home.file.${config.xdg.userDirs.templates}.source = ./templates;
  };
}
