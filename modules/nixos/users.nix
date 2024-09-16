{
  lib,
  config,
  self,
  specialArgs,
  ...
}: {
  options.custom.user = lib.mkOption {
    description = ''
      A user to create that can log in.

      The key is the user's login name, and the value
      is the user's configuration.

      Recommended usage: Create a file for the user in users/$\{userName}.nix
      This should be a function that takes pkgs, and returns a user configuration.
      ```nix
      pkgs: {
        core = {
          displayName = "YaBoiJonDoe";
          isSudoer = true; # At least one user needs sudo for admin tasks
          shell = pkgs.nushell;
        };

        home = {
          # Your home-manager configuration
        };
      }
      ```
    '';

    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        core = {
          displayName = lib.mkOption {
            description = ''
              The user's name as shown on the login screen.
            '';
            type = lib.types.str;
          };

          isSudoer = lib.mkOption {
            description = ''
              Whether the user should be able to sudo.
            '';
            type = lib.types.bool;
            default = false;
          };

          shell = lib.mkOption {
            description = ''
              The user's shell. Will be the default shell for all terminals.
            '';
            type = lib.types.package;
          };
        };

        home = lib.mkOption {
          description = ''
            Home-manager options for the user.

            See [home-manager's options](https://home-manager-options.extranix.com/) and
            [the home options of this flake](./user-options.md) for more information.
          '';

          # As stated above, this can be anything home-manager can handle, so can't be typed here
          type = lib.types.attrs;
        };
      };
    });
  };

  config = {
    home-manager = {
      # Inherit the global pkgs
      useGlobalPkgs = true;

      # Pass flake inputs plus host configuration
      extraSpecialArgs =
        specialArgs
        // {
          hostConfig = config;
        };

      # If a file to be provisioned already exists, back it up
      backupFileExtension = "backup";

      users =
        lib.attrsets.mapAttrs (name: user: {
          imports = [
            self.homeManagerModules.default
            user.home
          ];

          # Give home-manager some basic info about the user
          home.username = name;
          home.homeDirectory = "/home/${name}";
        })
        config.custom.user;
    };

    users.users =
      lib.attrsets.mapAttrs (name: user: {
        # A normal user is one that can log in, as opposed to a system user used for services
        isNormalUser = true;
        # User's full name
        description = user.core.displayName;

        # Everyone gets networkmanager membership so they can connect to networks
        # Only sudoers get wheel membership so they can sudo
        extraGroups =
          ["networkmanager"] ++ (lib.optional user.core.isSudoer "wheel");

        shell = user.core.shell;
      })
      config.custom.user;
  };
}
