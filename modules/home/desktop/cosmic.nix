# Per-user Cosmic settings
# See also: [[../nixos/cosmic.nix]]
{
  hostConfig,
  lib,
  config,
  ...
}: {
  options.custom.desktop.cosmic = let
    inherit (lib) mkOption types;

    settingsType = types.submodule {
      options = {
        version = mkOption {
          description = "Version prefix used for the app";
          type = types.str;
          default = "v1";
        };

        settings = mkOption {
          description = "Options for this application";
          type = types.attrsOf (types.oneOf [types.str types.int types.bool]);
          default = {};
        };
      };
    };
  in {
    settings = mkOption {
      description = "Settings for cosmic components. Key is the component name";
      type = types.attrsOf settingsType;
      default = {};
    };
  };

  config = let
    cfg = config.custom.desktop.cosmic;

    appSettings = app: let
      appConfig = cfg.settings.${app};
    in
      lib.attrsets.mapAttrsToList (name: value: {
        name = "${config.xdg.configHome}/cosmic/com.system76.${app}/${appConfig.version}/${name}";
        value.text = builtins.toString value;
      })
      appConfig.settings;

    settings = builtins.listToAttrs (lib.lists.flatten (map appSettings (builtins.attrNames cfg.settings)));
  in
    lib.mkIf (hostConfig.custom.desktop.environment == "cosmic") {
      home.file = settings;

      custom.desktop.cosmic.settings = {
        CosmicComp.settings = {
          active_hint = false;
        };
      };
    };
}
