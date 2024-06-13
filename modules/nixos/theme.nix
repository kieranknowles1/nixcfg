# Theme settings for the system
{ pkgs, flake, ... }:
{
  stylix = {
    # Stylix can generate a theme from the wallpaper, but in the images I've tested it came out ugly
    base16Scheme = "${pkgs.base16-schemes}/share/themes/da-one-gray.yaml";
    image = flake.lib.image.fromHeif ../../media/wallpaper.heic;

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

  home-manager.sharedModules = [{
    stylix.targets = {
      # Don't manage the VSCode theme, as I like the default dark and managing
      # with Stylix conflicts with home-manager's settings.json
      vscode.enable = false;
    };
  }];
}
