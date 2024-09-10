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

  options.custom.desktop = {
    templates = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {};

      description = ''
        A set of templates available for creating new files.

        These will be exposed via the right-click context menu in the desktop.

        Key is the name of the template, value is the path to its source file.
      '';
    };
  };

  config = lib.mkIf isDesktop {
    custom.desktop.templates = {
      "Empty File" = builtins.toFile "empty.txt" "";
    };

    # FIXME: Creating files from these templates makes a symlink to the store
    # Try impurity instead or an activation script
    # TODO: Use impurity for other config files
    home.file = lib.attrsets.mapAttrs' (name: path: {
      name = "${config.xdg.userDirs.templates}/${name}";
      value = {
        source = path;
      };
    }) config.custom.desktop.templates;
  };
}
