{
  self,
  pkgs,
  config,
}:
let
  inherit (self.lib.attrset) deepMergeSets;
  inherit (self.lib.host) readTomlFile;

  # We use TOML for host/user config, as they can be checked using schemas
  baseConfig = readTomlFile ./config.toml;
  desktopConfig = if config.custom.features.desktop then readTomlFile ./config-desktop.toml else { };
in
{
  core = {
    displayName = "Kieran";
    isSudoer = true;
    shell = pkgs.nushell;

    # Allow me to SSH between any of my hosts
    authorizedKeys = config.custom.ssh.keyOwners."kieranknowles11@hotmail.co.uk";
  };

  home = {
    # TOML configs can't specify packages or files, so use plain Nix for that
    imports = [
      ./config-nix.nix
    ];

    # Use a dedicated deepMergeSets function to merge the TOML files, as this
    # gives more easily understandable behaviour than options merging.
    custom = deepMergeSets [
      desktopConfig
      baseConfig
    ];

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
