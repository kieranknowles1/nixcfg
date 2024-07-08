{
  config,
  hostConfig,
  lib,
  ...
}: let
  userDetails = config.custom.userDetails;

  configDir = "${config.xdg.configHome}/espanso";
in {
  options.custom.userDetails = {
    email = lib.mkOption {
      description = "Email address";
      type = lib.types.str;
      example = "bob@example.com";
    };
    firstName = lib.mkOption {
      description = "First name";
      type = lib.types.str;
      example = "Bob";
    };
    surName = lib.mkOption {
      description = "Surname";
      type = lib.types.str;
      example = "Smith";
    };
  };

  # Espanso doesn't make sense on a headless server
  config = lib.mkIf (hostConfig.custom.deviceType == "desktop") {
    services.espanso = {
      enable = true;
      # Don't manage configs here, apart from the base match file
      # which we'll use for matches that use variables
      configs = {};
      matches.base = {
        matches = [
          {
            trigger = ":email:";
            replace = userDetails.email;
          }
          {
            trigger = ":name:";
            replace = "${userDetails.firstName} ${userDetails.surName}";
          }
          {
            triggers = [":firstname:" ":fname:"];
            replace = userDetails.firstName;
          }
          {
            triggers = [":surname:" ":sname:"];
            replace = userDetails.surName;
          }
        ];

        # Variables that we expose to all match files. Used when cleaner
        # than the Nix syntax or for app-specific match files
        global_vars = let
          # All variables in Espanso come from one of several sources.
          # We are only interested in constants here, so we use the echo
          # type to define them.
          # This is a helper as the syntax is a bit verbose
          mkGlobalVar = name: value: {
            name = name;
            type = "echo";
            params.echo = value;
          };
        in [
          (mkGlobalVar "email" userDetails.email)
          (mkGlobalVar "firstname" userDetails.firstName)
          (mkGlobalVar "surname" userDetails.surName)
        ];
      };
    };

    # Provision with home-manager so we can use yaml directly
    # This is linked to the schemas which gives us validation
    home.file."${configDir}" = {
      source = ./config;
      recursive = true;
    };

    # Link to our edit-config script
    custom.edit-config.programs.espanso = {
      system-path = configDir;
      repo-path = "modules/home/espanso/config";
      nix-managed-paths = [
        "match/base.yml" # Managed by espanso.matches.base
      ];
    };
  };
}
