{lib, ...}: {
  options.custom = {
    desktop.environment = lib.mkOption {
      description = "Desktop environment to use";
      type = lib.types.enum ["gnome"];
      default = "gnome";
    };
  };

  # Conditional imports tend to to cause infinite recursion, so we need to
  # condition within the imported file.
  imports = [
    ./gnome.nix
  ];
}
