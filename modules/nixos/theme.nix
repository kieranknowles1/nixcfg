# Theme settings for the system
{ pkgs, self, ... }:
{
  stylix = {
    # Stylix can generate a theme from the wallpaper, but in the images I've tested it came out ugly
    base16Scheme = "${pkgs.base16-schemes}/share/themes/da-one-gray.yaml";
    # image = ../../media/wallpaper.jpg;
    image = self.lib.image.fromHeif ../../media/wallpaper.heic;

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 16;
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
