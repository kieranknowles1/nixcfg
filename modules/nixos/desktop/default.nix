{
  lib,
  config,
  ...
}:
{
  options.custom.desktop =
    let
      inherit (lib) mkOption types;
    in
    {
      environment = mkOption {
        description = "Desktop environment to use";
        type = types.enum [
          # Would like this to be default, but it's not polished enough, especially in the Nix implementation
          # See [[./cosmic.nix]] for more information
          "cosmic"
          "gnome"
        ];
        default = "gnome";
      };
    };

  # Conditional imports tend to to cause infinite recursion, so we need to
  # condition within the imported file.
  imports = [
    ./cosmic.nix
    ./gnome.nix

    ./components.nix
  ];

  config = lib.mkIf config.custom.features.desktop {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      # Increase quantum (buffer size) to avoid
      # buffer underruns during lag spikes, which cause
      # buzzing
      extraConfig.pipewire = {
        "99-prevent-underrun" = {
          "context.properties" = {
            "default.clock.min-quantum" = 256;
          };
        };
      };
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
  };
}
