# Keyboard shortcuts managed by sxhkd
{ pkgs, config, ... }: let
  # TODO: Move this to the lib and use it for ReSaver
  /**
    Generate an XDG desktop entry file for a command.
    See https://wiki.archlinux.org/title/desktop_entries#Application_entry
    for more information.
   */
  mkDesktopEntry = { name, description, command }: ''
    [Desktop Entry]
    Type=Application
    Version=1.0
    Name=${name}
    Comment=${description}
    Exec=${command}
  '';
in {
  services.sxhkd = {
    enable = true;

    keybindings = {
      "alt + t" = "kgx"; # Open terminal
      "ctrl + alt + e" = "fsearch"; # Open FSearch (Everything clone)
      "ctrl + alt + Escape" = "gnome-system-monitor"; # Open task manager. Copy of Windows shortcut
    };
  };

  # Autostart sxhkd
  home.file."${config.xdg.configHome}/autostart/sxhkd.desktop".text = mkDesktopEntry {
    name = "sxhkd";
    description = "Simple X Hotkey Daemon";
    command = "sxhkd";
  };
}
