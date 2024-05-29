{ }:
{
  /**
    Create a user with a home-manager configuration for use with [lib.host.mkHost](#function-library-lib.host.mkhost).

    Configuration is sourced from `users/${userName}.nix` and the host's configuration is available
    through the `hostConfig` argument to modules.

    # Arguments
   */
  mkUser = {
    # Login name :: String
    userName,
    # Name shown in UIs :: String
    displayName,
    # Whether the user should be able to sudo :: Bool
    isSudoer ? false,
    # Package for the user's shell :: Package
    shell,
  }: {
    users.users.${userName} = {
      # A regular user that can log in
      isNormalUser = true;
      # User's full name
      description = displayName;

      # Give everyone "networkmanager" membership so they can connect to networks
      # Give sudoers "wheel" membership so they can sudo
      extraGroups = [ "networkmanager" ]
        ++ (if isSudoer then [ "wheel" ] else []);

      shell = shell;
    };

    home-manager.users.${userName} = {
      imports = [
        ../modules/home
        ../users/${userName}.nix
      ];

      # Home Manager needs a bit of information about you and the paths it should
      # manage.
      home.username = userName;
      home.homeDirectory = "/home/${userName}";
    };
  };
}
