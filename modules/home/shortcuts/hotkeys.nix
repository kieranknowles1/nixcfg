# Keyboard shortcuts managed by sxhkd
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs) sxhkd;

  mkDocs = bindings: let
    keys = builtins.attrNames bindings;

    bindingList = lib.lists.forEach keys (key: let
      value = bindings.${key};
    in "- `${key}` - ${value.description}");
  in ''
    # Keyboard shortcuts

    The following keyboard shortcuts are available globally:

    ${lib.strings.concatStringsSep "\n" bindingList}
  '';
in {
  options.custom.shortcuts = {
    hotkeys.keys = lib.mkOption {
      description = ''
        A set of keyboard shortcuts to be managed by sxhkd.
        The key in the set is the binding keysym names, and the value contains the action
        to be executed plus a description for documentation purposes.

        See [man sxhkd (1)](https://manpages.org/sxhkd) for more information on the
        syntax of keybindings.

        To get the keysym name for a key, run `xev`, press the desired key, and
        use the keysym it displays.
      '';

      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          action = lib.mkOption {
            type = lib.types.str;
            description = "The action to be executed when the keybinding is pressed";
          };
          description = lib.mkOption {
            type = lib.types.str;
            description = ''
              Brief, one-line description of the keybinding.

              Follow the same rules as the `description`
              [meta attribute](https://ryantm.github.io/nixpkgs/stdenv/meta/).
            '';
          };
        };
      });
    };
  };

  config = let
    cfg = config.custom.shortcuts;
  in
    lib.mkIf cfg.enable {
      # Default shortcuts
      custom.shortcuts.hotkeys.keys = {
        "alt + t" = {
          action = lib.getExe config.custom.terminal.package;
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
      # TODO: Add a keyboard visualizer to show shortcuts for held keys
      custom.docs-generate.file."shortcuts.md" = {
        description = "Keyboard shortcuts";
        dynamic = true;
        source = pkgs.writeText "shortcuts.md" (mkDocs cfg.hotkeys.keys);
      };

      # Apply options
      services.sxhkd = {
        enable = true;
        package = sxhkd;

        keybindings = builtins.mapAttrs (_name: value: value.action) cfg.hotkeys.keys;
      };

      # Enable xsession which starts sxhkd
      xsession.enable = true;

      # Restart sxhkd when reloading the configuration
      # Activation scripts are run on boot, and when switching to a new configuration
      home.activation."restart-sxhkd" = lib.hm.dag.entryAfter ["writeBoundary"] ''
        restart_sxhkd() {
          local pid=$(${pkgs.procps}/bin/pidof sxhkd)
          if [ -n "$pid" ]; then
            # Send SIGUSR1 to reload the configuration
            ${pkgs.coreutils}/bin/kill -USR1 $pid
          fi
        }

        run restart_sxhkd
      '';
    };
}
