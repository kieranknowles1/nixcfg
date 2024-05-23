# Theme settings for the system
{ pkgs, ... }:
{
  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    image = ../../media/wallpaper.jpg;
  };

  home-manager.sharedModules = [{
    stylix.targets = {
      vscode.enable = false;
    };
  }];
}