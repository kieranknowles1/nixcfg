{
 config,
 lib,
  ...
}: let
  userDetails = config.custom.userDetails;
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

  config = {
    services.espanso = {
      enable = true;
      # Don't manage configs here, apart from the base match file
      # which we'll use for matches that use variables
      configs = {};
      matches = {
        base.matches = [
          { trigger = ":email:"; replace = userDetails.email; }
          { trigger = ":name:"; replace = "${userDetails.firstName} ${userDetails.surName}"; }
          { triggers = [":firstname:" ":fname:"]; replace = userDetails.firstName; }
          { triggers = [":surname:" ":sname:"]; replace = userDetails.surName; }
        ];
      };
    };

    # Provision with home-manager so we can use yaml directly
    # This is linked to the schemas which gives us validation
    home.file."${config.xdg.configHome}/espanso/" = {
      source = ./config;
      recursive = true;
    };
  };
}
