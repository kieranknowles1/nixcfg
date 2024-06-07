{
 config,
 lib,
  ...
}: let
  mkMatch = trigger: replace: {
    inherit trigger replace;
  };
in {
  options = {
    custom.email = lib.mkOption {
      description = "Email address";
      type = lib.types.str;
      example = "bob@example.com";
    };
    custom.fullName = lib.mkOption {
      description = "Full name";
      type = lib.types.str;
      example = "Bob Smith";
    };
  };

  config = {
    services.espanso = {
      enable = true;
      # Don't manage configs here, apart from the default match file
      # which we'll use for matches that use variables
      configs = {};
      matches = {
        default.matches = [
          (mkMatch ":email:" config.custom.email)
          (mkMatch ":name:" config.custom.fullName)
        ];
      };
    };

    # Provision with home-manager so we can use yaml directly
    home.file."${config.xdg.configHome}/espanso/" = {
      source = ./config;
      recursive = true;
    };
  };
}
