# Keyboard shortcuts managed by sxhkd
{
  config,
  hostConfig,
  lib,
  flake,
  pkgs,
  ...
}: let
  sxhkd = pkgs.sxhkd;

  mkDocs = bindings: let
    keys = builtins.attrNames bindings;

    bindingList = lib.lists.forEach keys (key: let
      description = bindings.${key}.description;
    in "- `${key}` - ${description}");
  in ''
    # Keyboard shortcuts

    The following keyboard shortcuts are available globally:

    ${lib.strings.concatStringsSep "\n" bindingList}
  '';
in {
  options.custom = {
    shortcuts = lib.mkOption {
      description = ''
        A set of keyboard shortcuts to be managed by sxhkd.
        The key in the set is the binding, and the value contains the action to be executed and
        a description for documentation purposes.
      '';

      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          action = lib.mkOption {
            type = lib.types.str;
            description = "The action to be executed when the keybinding is pressed";
          };
          description = lib.mkOption {
            type = lib.types.str;
            description = "Brief, one-line description of the keybinding";
          };
        };
      });
    };
  };

  config = lib.mkIf (hostConfig.custom.deviceType == "desktop") {
    # Default shortcuts
    custom.shortcuts = {
      "alt + t" = {
        action = "kgx";
        description = "Open terminal";
      };
      "ctrl + alt + e" = {
        action = "fsearch";
        description = "Open FSearch (Everything clone)";
      };
      "ctrl + shift + Escape" = {
        action = "resources";
        description = "Open task manager.";
      };
    };

    # Generate documentation
    custom.docs-generate.file."shortcuts.md" = {
      description = "Keyboard shortcuts";
      source = builtins.toFile "shortcuts.md" (mkDocs config.custom.shortcuts);
    };

    # Apply options
    services.sxhkd = {
      enable = true;
      package = sxhkd;

      keybindings = builtins.mapAttrs (name: value: value.action) config.custom.shortcuts;
    };

    # Autostart sxhkd
    # TODO: Restart when rebuilding, try something similar to the MIME database update
    home.file."${config.xdg.configHome}/autostart/sxhkd.desktop".text = flake.lib.package.mkDesktopEntry {
      name = "sxhkd";
      description = "Simple X Hotkey Daemon";
      command = "sxhkd";
      version = sxhkd.version;
    };
  };
}
