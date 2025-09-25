{
  self,
  pkgs,
  config,
}: {
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
      ./configuration.nix
      ./desktop.nix
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
