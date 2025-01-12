{
  lib,
  config,
  self,
  specialArgs,
  inputs,
  ...
}: {
  options.custom.users.users = lib.mkOption {
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

  config = let
    cfg = config.custom.users;

    mkHome = name: user: {
      imports = [
        self.homeManagerModules.default
        user.home
      ];

      # Give home-manager some basic info about the user
      home.username = name;
      home.homeDirectory = "/home/${name}";
    };

    mkNixos = _name: user: {
      inherit (user.core) shell;

      isNormalUser = true;
      description = user.core.displayName;

      # Everyone can manage network connections, but only sudoers can use
      # sudo
      extraGroups =
        ["networkmanager"] ++ (lib.optional user.core.isSudoer "wheel");
    };
  in {
    home-manager = {
      useGlobalPkgs = true; # Inherit any configuration to nixpkgs, such as allowUnfree
      # Pass flake inputs plus host configuration
      extraSpecialArgs =
        specialArgs
        // {
          hostConfig = config;
        };

      # If a file to be provisioned already exists, back it up
      backupFileExtension = "backup";

      sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
        self.homeManagerModules.default
      ];

      users = lib.attrsets.mapAttrs mkHome cfg.users;
    };

    users.users = lib.attrsets.mapAttrs mkNixos cfg.users;
  };
}
