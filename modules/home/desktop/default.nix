{
  lib,
  config,
  hostConfig,
  pkgs,
  ...
}: {
  imports = [
    ./cosmic.nix
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

  config = lib.mkIf hostConfig.custom.features.desktop {
    custom.desktop.templates = {
      "Empty File" = builtins.toFile "empty.txt" "";
    };

    custom.mutable.file =
      lib.attrsets.mapAttrs' (name: value: {
        name = "${config.xdg.userDirs.templates}/${name}";
        value = {
          source = value;
        };
      })
      config.custom.desktop.templates;

    custom.shortcuts.hotkeys.keys = let
      adjustBrightness = amount: action: key: {
        inherit key;
        alt = true;
        shift = true;
        action = "${pkgs.flake.nix-utils}/bin/modbright ${toString amount}";
        description = "${action} display brightness";
      };
    in [
      (adjustBrightness 0.1 "Increase" "Home")
      (adjustBrightness (-0.1) "Decrease" "End")
    ];
  };
}
