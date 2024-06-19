# Keyboard shortcuts managed by AutoKey
{ pkgs, config, ... }:
{
  services.sxhkd = {
    enable = true;

    keybindings = {
      "alt + t" = "kgx"; # Open terminal
      "ctrl + alt + e" = "fsearch"; # Open FSearch (Everything clone)
      "ctrl + alt + Escape" = "gnome-system-monitor"; # Open task manager. Copy of Windows shortcut
    };
  };
}
