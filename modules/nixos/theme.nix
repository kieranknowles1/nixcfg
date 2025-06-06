# Theme settings for the system
{
  pkgs,
  config,
  ...
}: {
  stylix = {
    # No need to theme the system if it's a server
    enable = config.custom.features.desktop;

    # Stylix can generate a theme from the wallpaper, but in the images I've tested it came out ugly
    # This is overridden in home-manager
    base16Scheme = "${pkgs.base16-schemes}/share/themes/da-one-gray.yaml";

    polarity = "dark"; # Force a dark theme

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 16;
    };

    targets = {
      # Don't style boot messages, as I prefer the default
      console.enable = false;
      grub.enable = false;
    };
  };

  home-manager.sharedModules = [
    {
      stylix.targets = {
        # Don't manage the VSCode theme, as I like the default dark and managing
        # with Stylix conflicts with home-manager's settings.json
        vscode.enable = false;
      };
    }
  ];
}
