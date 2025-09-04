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

  options.custom.desktop = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    templates = mkOption {
      type = types.attrsOf types.path;
      default = {};

      description = ''
        A set of templates available for creating new files.

        These will be exposed via the right-click context menu in the desktop.

        Key is the name of the template, value is the path to its source file.
      '';
    };

    modbright.enable = mkEnableOption "brightness modifier keys";
  };

  config = let
    cfg = config.custom.desktop;
  in
    lib.mkIf hostConfig.custom.desktop.enable {
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
        cfg.templates;

      custom.shortcuts.hotkeys.keys = let
        adjustBrightness = amount: action: key: {
          inherit key;
          alt = true;
          shift = true;
          action = "${pkgs.flake.nix-utils}/bin/modbright ${toString amount}";
          description = "${action} display brightness";
        };
      in
        lib.optionals cfg.modbright.enable [
          (adjustBrightness 0.1 "Increase" "Home")
          (adjustBrightness (-0.1) "Decrease" "End")
        ];
    };
}
