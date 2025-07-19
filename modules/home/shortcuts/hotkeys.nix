# Keyboard shortcuts managed by sxhkd
{
  config,
  hostConfig,
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs) sxhkd;

  keySym = binding:
    builtins.concatStringsSep " + " (
      (lib.optional binding.ctrl "ctrl")
      ++ (lib.optional binding.alt "alt")
      ++ (lib.optional binding.shift "shift")
      ++ [binding.key]
    );

  mkDocs = bindings: let
    bindingList =
      lib.lists.forEach bindings
      (binding: "- `${keySym binding}` - ${binding.description}");
  in ''
    # Keyboard shortcuts

    The following keyboard shortcuts are available globally:

    ${lib.strings.concatStringsSep "\n" bindingList}
  '';
in {
  options.custom.shortcuts.hotkeys = let
    inherit (lib) mkOption mkPackageOption mkEnableOption types;

    mkModifierOption = default: name:
      mkOption {
        inherit default;
        type = types.bool;
        description = "Whether ${name} must be pressed in addition to the keybinding";
      };
  in {
    enable = mkEnableOption "keyboard shortcuts";

    keys = mkOption {
      description = ''
        A set of keyboard shortcuts to be managed by sxhkd.

        See [man sxhkd (1)](https://manpages.org/sxhkd) for more information on the
        syntax of keybindings.
      '';

      type = types.listOf (types.submodule {
        options = {
          key = mkOption {
            type = types.str;
            example = "t";
            description = ''
              The keysym name for the key to be pressed.

              To get the keysym name for a key, run `xev`, press the desired key, and
              use the keysym it displays.
            '';
          };

          alt = mkModifierOption false "alt";
          ctrl = mkModifierOption false "ctrl";
          shift = mkModifierOption false "shift";

          action = mkOption {
            type = types.str;
            description = "The action to be executed when the keybinding is pressed";
          };

          description = mkOption {
            type = types.str;
            description = ''
              Brief, one-line description of the keybinding.

              Follow the same rules as the `description`
              [meta attribute](https://ryantm.github.io/nixpkgs/stdenv/meta/).
            '';
          };

          icon = mkOption {
            type = types.nullOr types.path;
            description = "Icon to be displayed in `keyboardvis`";
            default = null;
          };
        };
      });
    };

    visualiser = {
      enable = mkEnableOption "hotkey visualiser";
      package = mkPackageOption pkgs.flake "keyboardvis" {};

      binding = {
        key = mkOption {
          type = types.str;
          description = "Key to be pressed";
          default = "v";
        };
        alt = mkModifierOption true "alt";
        ctrl = mkModifierOption false "ctrl";
        shift = mkModifierOption true "shift";
      };

      build.config = mkOption {
        type = types.package;
        description = "Config file for `keyboardvis`";
      };
    };
  };

  config = let
    cfg = config.custom.shortcuts.hotkeys;

    # WTF: removeAttrs takes item-action instead of action-item, opposite to standard practice
    # this means we can't use it partially applied
    removeAction = entry: builtins.removeAttrs entry ["action"];
  in
    lib.mkIf cfg.enable {
      assertions = lib.singleton {
        assertion = hostConfig.custom.features.desktop;
        message = "Hotkeys require a desktop environment";
      };

      custom.shortcuts.hotkeys.visualiser = {
        build.config =
          pkgs.writeText "keyboard-vis.json"
          (builtins.toJSON (map removeAction cfg.keys));
      };

      # Default shortcuts
      custom.shortcuts.hotkeys.keys =
        [
          {
            key = "t";
            alt = true;
            action = lib.getExe config.custom.terminal.package;
            # TODO: Don't always use Alacritty icon
            icon = "${config.custom.terminal.package}/share/icons/hicolor/scalable/apps/Alacritty.svg";
            description = "Terminal";
          }
          {
            key = "e";
            ctrl = true;
            alt = true;
            action = lib.getExe pkgs.fsearch;
            icon = "${pkgs.fsearch}/share/icons/hicolor/scalable/apps/io.github.cboxdoerfer.FSearch.svg";
            description = "FSearch";
          }
          {
            key = "Escape";
            ctrl = true;
            shift = true;
            action = lib.getExe pkgs.resources;
            icon = "${pkgs.resources}/share/icons/hicolor/scalable/apps/net.nokyan.Resources.svg";
            description = "Task manager";
          }
        ]
        ++ (lib.optional cfg.visualiser.enable {
          inherit (cfg.visualiser.binding) key ctrl alt shift;
          action = "${lib.getExe cfg.visualiser.package} -- ${cfg.visualiser.build.config}";
          description = "Visualise hotkeys";
        });

      # Generate documentation
      # TODO: Add a keyboard visualizer to show shortcuts for held keys
      custom.docs-generate.file."shortcuts.md" = {
        description = "Keyboard shortcuts";
        dynamic = true;
        source = pkgs.writeText "shortcuts.md" (mkDocs cfg.keys);
      };

      # Apply options
      services.sxhkd = {
        enable = true;
        package = sxhkd;

        keybindings = builtins.listToAttrs (map (e: {
            name = keySym e;
            value = e.action;
          })
          cfg.keys);
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
