{
  lib,
  config,
  ...
}: {
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

  config = lib.mkIf (config.custom.deviceType == "desktop") {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable sound with pipewire.
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
  };
}
