# MIME definitions and associations
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Base directory for MIME definitions. The definitions themselves
  # are stored in the `packages` subdirectory.
  mime-directory = "${config.xdg.dataHome}/mime";
in {
  # Copy definitions into the user's mime directory
  home.file."${mime-directory}/packages" = {
    source = ./definitions;
    recursive = true;
  };

  # Update the user's mime database when rebuilding
  home.activation.update-mime-database = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.shared-mime-info}/bin/update-mime-database "${mime-directory}"
  '';
}
