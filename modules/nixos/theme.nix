# Theme settings for the system
{ pkgs, ... }:
{
  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/da-one-gray.yaml";
    image = ../../media/wallpaper.jpg;

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 16;
    };
  };

  home-manager.sharedModules = [{
    stylix.targets = {
      vscode.enable = false;
    };
  }];
}