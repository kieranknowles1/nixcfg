# Theme settings for the system
{ pkgs, ... }:
{
  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/da-one-black.yaml";
    image = ../../media/wallpaper.jpg;
  };

  home-manager.sharedModules = [{
    stylix.targets = {
      vscode.enable = false;
    };
  }];
}