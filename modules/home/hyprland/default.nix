# Hyprland user config
# See also: [[../../nixos/hyprland.nix]]
{
  flake,
  hostConfig,
  inputs,
  config,
  system,
  pkgs,
  ...
}: let
  # This step needs the daemon to start and then called in a specific order, so do it in a script
  # FIXME: This causes a delay on startup, maybe try a different daemon
  setWallpaper = image: let
    swww = pkgs.swww;

    script = pkgs.writeShellScriptBin "set-wallpaper" ''
      ${swww}/bin/swww-daemon &
      sleep 1 # Give the daemon time to start
      ${swww}/bin/swww img "${image}"
    '';
  in "${script}/bin/set-wallpaper";

  hostHyprConfig = hostConfig.custom.hyprland;

  hyprland = inputs.hyprland.packages.${system}.hyprland;
in {
  config = {
    # Manage hyprland with home-manager
    wayland.windowManager.hyprland = {
      enable = true;
      package = hyprland;

      # This gets transformed into hyprland syntax for hyprland.conf
      # Refer to the wiki for more information.
      # https://wiki.hyprland.org/Configuring/Configuring-Hyprland/
      # TODO: Need to run hyprctl reload manually. Should be automated as part of rebuild
      # An activation script doesn't work for some reason
      settings = {
        # == Per Host ==
        monitor = hostHyprConfig.monitors;

        # Paths can't be used directly, so we need to map them to strings
        # toString on a path will give the full path to the file in the store
        # While Hyprland's Nix module is great for some things, standalone files are better
        # for some things like keybinds, for reasons explained in the individual conf files
        source = (builtins.map builtins.toString [
          ./config/keybinds.conf
        ]);

        input = {
          kb_layout = "gb";
        };

        # == Look and Feel ==
        general = {
          # Default gaps are a bit aggressive, a few pixels is enough
          gaps_in = 0; # Between windows
          gaps_out = 0; # Between windows and screen edge
          border_size = 1; # Keep it present so we can see which window is focused, but not too big to be distracting

          allow_tearing = true; # Tearing is less distracting than stuttering/flickering to the previous frame
        };

        env = [
          # Disable APIs that don't support tearing
          # TODO: This can be disabled once we are on kernel 6.8
          "WLR_DRM_NO_ATOMIC,1"
        ];

        decoration = {
          rounding = 0; # Rounded corners feel "mobile first" to me

          blur = {
            enabled = false; # Prefer to keep transparent backgrounds transparent
          };
        };

        exec-once = [
          (setWallpaper (flake.lib.image.fromHeif ../../../media/wallpaper.heic))
          "ags" # Widgets and whatever you can do in JS
        ];

        # == Window Rules ==
        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
        windowrulev2 = [
          "float, class:^(fsearch)$"
          "float, class:^(kitty)$"
          "float, class:^(resources)$"

          # Enable tearing for games running under Proton
          # NOTE: This only works in fullscreen mode
          "immediate, class:^(steam_app_\d+)$"
        ];
      };
    };

    programs.ags = {
      enable = true;

      configDir = ./ags;
    };

    # Provision AGS type stubs
    home.file."${config.custom.repoPath}/modules/home/hyprland/ags/types" = {
      source = "${inputs.ags.packages.${system}.default}/share/com.github.Aylur.ags/types";
    };
  };
}

# # TODO: Port this all to nix

# #####################
# ### LOOK AND FEEL ###
# #####################

# # https://wiki.hyprland.org/Configuring/Variables/#general
# general {
#     # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
#     col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
#     col.inactive_border = rgba(595959aa)
#     layout = dwindle
# }

# # https://wiki.hyprland.org/Configuring/Variables/#decoration
# decoration {
#     # Change transparency of focused and unfocused windows
#     active_opacity = 1.0
#     inactive_opacity = 1.0

#     drop_shadow = true
#     shadow_range = 4
#     shadow_render_power = 3
#     col.shadow = rgba(1a1a1aee)
# }

# # https://wiki.hyprland.org/Configuring/Variables/#animations
# animations {
#     enabled = true

#     # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

#     bezier = myBezier, 0.05, 0.9, 0.1, 1.05

#     animation = windows, 1, 7, myBezier
#     animation = windowsOut, 1, 7, default, popin 80%
#     animation = border, 1, 10, default
#     animation = borderangle, 1, 8, default
#     animation = fade, 1, 7, default
#     animation = workspaces, 1, 6, default
# }

# # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
# dwindle {
#     pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
#     preserve_split = true # You probably want this
# }

# # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
# master {
#     new_is_master = true
# }

# # https://wiki.hyprland.org/Configuring/Variables/#misc
# misc {
#     force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
#     disable_hyprland_logo = false # If true disables the random hyprland logo / anime girl background. :(
# }


# #############
# ### INPUT ###
# #############

# # https://wiki.hyprland.org/Configuring/Variables/#input
# input {
#     kb_variant =
#     kb_model =
#     kb_options =
#     kb_rules =

#     follow_mouse = 1

#     sensitivity = 0 # -1.0 - 1.0, 0 means no modification.

#     touchpad {
#         natural_scroll = false
#     }
# }

# # https://wiki.hyprland.org/Configuring/Variables/#gestures
# gestures {
#     workspace_swipe = false
# }

# # Example per-device config
# # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
# device {
#     name = epic-mouse-v1
#     sensitivity = -0.5
# }


# ####################
# ### KEYBINDINGSS ###
# ####################

# # My keybinds
# # TODO: Replace example binds with my own

# # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
# bind = $mainMod, C, killactive,
# bind = $mainMod, M, exit,
# bind = $mainMod, E, exec, $fileManager
# bind = $mainMod, V, togglefloating,
# bind = $mainMod, P, pseudo, # dwindle
# bind = $mainMod, J, togglesplit, # dwindle

# # Move focus with mainMod + arrow keys
# bind = $mainMod, left, movefocus, l
# bind = $mainMod, right, movefocus, r
# bind = $mainMod, up, movefocus, u
# bind = $mainMod, down, movefocus, d

# # Example special workspace (scratchpad)
# bind = $mainMod, S, togglespecialworkspace, magic
# bind = $mainMod SHIFT, S, movetoworkspace, special:magic

# # Scroll through existing workspaces with mainMod + scroll
# bind = $mainMod, mouse_down, workspace, e+1
# bind = $mainMod, mouse_up, workspace, e-1
