# MIME definitions and associations
{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.mime = let
    inherit (lib) mkOption types options;
  in {
    # TODO: Rename this to something more general, like `types` or `associations`
    definition = mkOption {
      description = ''
        A list of MIME definitions and associated default applications.

        The key is the MIME type being defined, and the value is its definition
        file. See http://www.freedesktop.org/standards/shared-mime-info
        for the specification of these files.
      '';

      example = {
        "application/x-foo" = {
          definitionFile = "./definitions/application-x-foo.xml";
          defaultApp = "myapp.desktop";
        };
        "application/pdf" = {
          defaultApp = "firefox.desktop";
        };
      };

      type = types.attrsOf (types.submodule {
        options = {
          definitionFile = mkOption {
            description = "The path to the MIME definition file";
            type = types.nullOr types.path;
            default = null;
            example = options.literalExpression "./definitions/application-x-foo.xml";
          };
          defaultApp = mkOption {
            description = ''
              The name of the *.desktop file to use as the default application

              This must be a *.desktop file in one of the [Standard Directories](https://unix.stackexchange.com/a/615323).
              On NixOS, these are:
              - /run/current-system/sw/share/applications
              - ~/.local/share/applications
              - ~/.nix-profile/share/applications

              This is not checked, so should be the first thing you verify if things aren't working as expected.
            '';
            type = types.nullOr types.str;
            default = null;
            example = "myapp.desktop";
          };
        };
      });
      # No definitions is valid, so default to an empty set
      default = {};
    };
  };

  config = let
    cfg = config.custom.mime;

    # Base directory for MIME definitions. The definitions themselves
    # are stored in the `packages` subdirectory.
    mimeDirectory = "${config.xdg.dataHome}/mime";

    # Convert a MIME type to a definition file name
    toFileName = type: "${builtins.replaceStrings ["/"] ["-"] type}.xml";

    toHomeFileEntry = name: value: {
      name = "${mimeDirectory}/packages/${toFileName name}";
      value = {
        source = value.definitionFile;
      };
    };

    toXdgAssociation = name: value: {
      inherit name; # Name is the MIME type
      value = value.defaultApp;
    };

    definitionFiles =
      lib.attrsets.mapAttrs' toHomeFileEntry
      (lib.attrsets.filterAttrs (_name: value: value.definitionFile != null) cfg.definition);
  in {
    # Copy definitions into the user's mime directory
    home.file = definitionFiles;

    xdg.mimeApps = {
      enable = cfg.definition != {};

      associations.added =
        lib.attrsets.mapAttrs' toXdgAssociation
        (lib.attrsets.filterAttrs (_name: value: value.defaultApp != null) cfg.definition);
    };

    # Update the user's mime database when rebuilding
    home.activation = lib.mkIf (definitionFiles != {}) {
      update-mime-database = lib.hm.dag.entryAfter ["writeBoundary"] ''
        run ${pkgs.shared-mime-info}/bin/update-mime-database "${mimeDirectory}"
      '';
    };
  };
}
