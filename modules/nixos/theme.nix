# Theme settings for the system
{
  lib,
  inputs,
  pkgs,
  config,
  ...
}: {
  stylix = {
    # No need to theme the system if it's a server
    enable = config.custom.desktop.enable;

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

  # HACK: Stylix isn't imported on home side if it isn't enabled host-wide.
  # This makes configuration fail as it tries to set an undefined option.
  # Disabling auto import would break home-manager inheritance and double import
  # breaks completely, so condition the import based on it being disabled
  # (and home disabling it anyway meaning we import an unused module)
  home-manager.sharedModules =
    lib.optional (!config.custom.desktop.enable)
    inputs.stylix.homeModules.stylix;
}
