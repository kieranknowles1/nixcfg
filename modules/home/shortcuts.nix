# Keyboard shortcuts managed by sxhkd
{
  config,
  flake,
  ...
}: {
  services.sxhkd = {
    enable = true;

    keybindings = {
      "alt + t" = "kgx"; # Open terminal
      "ctrl + alt + e" = "fsearch"; # Open FSearch (Everything clone)
      "ctrl + shift + Escape" = "resources"; # Open task manager. Copy of Windows shortcut
    };
  };

  # Autostart sxhkd
  home.file."${config.xdg.configHome}/autostart/sxhkd.desktop".text = flake.lib.package.mkDesktopEntry {
    name = "sxhkd";
    description = "Simple X Hotkey Daemon";
    command = "sxhkd";
  };
}
