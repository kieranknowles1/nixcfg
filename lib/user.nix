{
  ...
}:
{
  # Function to create a user for a host
  mkUser = {
    userName, # Login name
    displayName, # Name shown in UIs
    isSudoer ? false, # Whether the user should be able to sudo
    shell, # Package for the user's shell
  }: {
    users.users.${userName} = {
      # A regular user that can log in
      isNormalUser = true; # A regular user that can log in
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
