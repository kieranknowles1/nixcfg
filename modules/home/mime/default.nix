# MIME definitions and associations
{
  config,
  lib,
  pkgs,
  ...
}: let
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
in {
  options.custom.mime = {
    definition = lib.mkOption {
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

      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          definitionFile = lib.mkOption {
            description = "The path to the MIME definition file";
            type = lib.types.nullOr lib.types.path;
            default = null;
            example = "./definitions/application-x-foo.xml";
          };
          defaultApp = lib.mkOption {
            description = "The name of the *.desktop file to use as the default application";
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "myapp.desktop";
          };
        };
      });
      # No definitions is valid, so default to an empty set
      default = {};
    };
  };

  config = {
    # Copy definitions into the user's mime directory
    home.file =
      lib.attrsets.mapAttrs' toHomeFileEntry
      (lib.attrsets.filterAttrs (_name: value: value.definitionFile != null) config.custom.mime.definition);

    xdg.mimeApps = {
      enable = true;

      associations.added =
        lib.attrsets.mapAttrs' toXdgAssociation
        (lib.attrsets.filterAttrs (_name: value: value.defaultApp != null) config.custom.mime.definition);
    };

    # Update the user's mime database when rebuilding
    home.activation.update-mime-database = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${pkgs.shared-mime-info}/bin/update-mime-database "${mimeDirectory}"
    '';
  };
}
