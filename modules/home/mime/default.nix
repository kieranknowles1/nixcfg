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

  parseConfigEntry = name: value: {
    name = "${mimeDirectory}/packages/${toFileName name}";
    value = {
      source = value;
    };
  };
in {
  options.custom.mime = {
    # TODO: This could handle associations as well
    definition = lib.mkOption {
      description = ''
        A list of MIME definitions files to install.

        The key is the MIME type being defined, and the value is its definition
        file. See http://www.freedesktop.org/standards/shared-mime-info
        for the specification of these files.
      '';

      example = ''
        {
          "application/x-foo" = ./definitions/application-x-foo.xml;
          "application/x-bar" = ./definitions/application-x-bar.xml;
        }
      '';

      type = lib.types.attrsOf lib.types.path;
      # No definitions is valid, so default to an empty set
      default = {};
    };
  };

  config = {
    # Copy definitions into the user's mime directory
    home.file = lib.attrsets.mapAttrs' parseConfigEntry config.custom.mime.definition;

    # Update the user's mime database when rebuilding
    home.activation.update-mime-database = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.shared-mime-info}/bin/update-mime-database "${mimeDirectory}"
    '';
  };
}
