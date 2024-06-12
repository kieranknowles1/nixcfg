# Hyprland user config
# See also: [[../nixos/hyprland.nix]]
{
  lib,
  flake,
  hostConfig,
  inputs,
  system,
  pkgs,
  ...
}: let
  # TODO: Give this a better name, move to lib, and make generic, and document
  # Nix is a functional language, so we can only iterate through recursion
  _repeatForDigitsImpl = str: current: if current < 10
    then [(builtins.replaceStrings ["#"] [(builtins.toString current)] str)] ++ (_repeatForDigitsImpl str (current + 1))
    else [];

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


  repeatForDigits = str: _repeatForDigitsImpl str 1;

  hostHyprConfig = hostConfig.custom.hyprland;

  hyprland = inputs.hyprland.packages.${system}.hyprland;
  windows = "SUPER"; # Windows key
  ags = "${pkgs.ags}/bin/ags";
  terminal = "${pkgs.kitty}/bin/kitty";
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

        "$ags" = "${pkgs.ags}/bin/ags";

        # Paths can't be used directly, so we need to map them to strings
        # toString on a path will give the full path to the file in the store
        # While Hyprland's Nix module is great for some things, standalone files are better
        # for some things like keybinds, for reasons explained in the individual conf files
        source = (builtins.map builtins.toString [
          ./config/keybinds.conf
        ]);

        # == Input ==
        # TODO: Move all this to keybinds.conf
        bind = [
          # Win + T -> Open terminal
          "${windows}, T, exec, ${terminal}"
          # Win + F -> Toggle floating
          "${windows}, F, togglefloating"

          # Add the standard keybinds
          "ALT, F4, killactive"
          "ALT, Tab, cyclenext"
          "ALT Shift, Tab, cyclenext, prev"

          # Toggle mute
          ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        # Move windows between monitors with Win+digit
        ] ++ (repeatForDigits "${windows}, #, movetoworkspace, #");

        # Media keys
        # TODO: Add a widget on change
        # TODO: Get play/pause working somehow
        binde = [
          ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioRaiseVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0"
          ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioLowerVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0"
        ];

        input = {
          kb_layout = "gb";
        };

        # == Look and Feel ==
        general = {
          # Default gaps are a bit aggressive, a few pixels is enough
          gaps_in = 0; # Between windows
          gaps_out = 0; # Between windows and screen edge
          border_size = 1; # Keep it present so we can see which window is focused, but not too big to be distracting
        };

        decoration = {
          rounding = 0; # Rounded corners feel "mobile first" to me
        };

        exec-once = [
          (setWallpaper (flake.lib.image.fromHeif ../../../media/wallpaper.heic))
          ags # Widgets and whatever you can do in JS
        ];
      };
    };

    # TODO: Get this working to manage the config
    # programs.ags = {
    #   enable = true;

    #   configDir = ./ags;
    # };
  };
}

# # TODO: Port this all to nix
# # This is an example Hyprland config file.

# # Please note not all available settings / options are set here.
# # For a full list, see the wiki

# # You can split this configuration into multiple files
# # Create your files separately and then link them to this file like this:
# # source = ~/.config/hypr/myColors.conf


# ###################
# ### MY PROGRAMS ###
# ###################

# # See https://wiki.hyprland.org/Configuring/Keywords/

# # Set programs that you use
# $fileManager = nautilus


# #################
# ### AUTOSTART ###
# #################

# # Autostart necessary processes (like notifications daemons, status bars, etc.)
# # Or execute your favorite apps at launch like this:

# # exec-once = $terminal
# # exec-once = nm-applet &
# # exec-once = waybar & hyprpaper & firefox

# exec-once = swww-daemon # Wallpaper daemon
# # exec-once = waybar # Status bar
# exec-once = mako # Notifications

# #############################
# ### ENVIRONMENT VARIABLES ###
# #############################

# # See https://wiki.hyprland.org/Configuring/Environment-variables/

# env = XCURSOR_SIZE,24
# env = HYPRCURSOR_SIZE,24


# #####################
# ### LOOK AND FEEL ###
# #####################

# # Refer to https://wiki.hyprland.org/Configuring/Variables/

# # https://wiki.hyprland.org/Configuring/Variables/#general
# general {
#     # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
#     col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
#     col.inactive_border = rgba(595959aa)

#     # Set to true enable resizing windows by clicking and dragging on borders and gaps
#     resize_on_border = false

#     # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
#     allow_tearing = false

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

#     # https://wiki.hyprland.org/Configuring/Variables/#blur
#     blur {
#         enabled = true
#         size = 3
#         passes = 1

#         vibrancy = 0.1696
#     }
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

# # See https://wiki.hyprland.org/Configuring/Keywords/
# $mainMod = SUPER # Sets "Windows" key as main modifier

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

# ##############################
# ### WINDOWS AND WORKSPACES ###
# ##############################

# # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
# # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

# # Example windowrule v1
# # windowrule = float, ^(kitty)$

# # Example windowrule v2
# # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$

# windowrulev2 = suppressevent maximize, class:.* # You'll probably like this.
