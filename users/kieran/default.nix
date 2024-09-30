{
  self,
  pkgs,
  config,
}: let
  inherit (self.lib.attrset) deepMergeSets;
  inherit (self.lib.host) readTomlFile;

  isDesktop = config.custom.deviceType == "desktop";

  baseConfig = readTomlFile ./config.toml;
  desktopConfig =
    if isDesktop
    then readTomlFile ./config.toml
    else {};

  # Values that can't be configured in the TOML files
  nixOnlyConfig = {
    theme.wallpaper = self.lib.image.fromHeif ./wallpaper.heic;

    secrets.ageKeyFile = "/home/kieran/.config/sops/age/keys.txt";
    secrets.file = ./secrets.yaml;
  };
in {
  core = {
    displayName = "Kieran";
    isSudoer = true;
    shell = pkgs.nushell;
  };

  home = {
    # Use a dedicated deepMergeSets function to merge the TOML files, as this
    # gives more easily understandable behaviour than options merging.
    custom = deepMergeSets [nixOnlyConfig desktopConfig baseConfig];

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "23.11"; # Please read the comment before changing.
  };
}
