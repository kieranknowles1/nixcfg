# Core configuration needed for any host
{
  pkgs,
  pkgs-unstable,
  flake,
  lib,
  system,
  ...
}: let
  # Helper to activate a dev shell
  develop = pkgs.writeShellScriptBin "develop" ''
    nix develop "$FLAKE#$1"
  '';
in {
  options.custom = {
    deviceType = lib.mkOption {
      description = "The type of device this configuration is for.";

      type = lib.types.enum [
        "desktop"
        "server"
      ];
    };
  };

  config = {
    # Enable flakes
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

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

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      develop # Our nix develop helper
      git # This configuration is in a git repository, so it's an essential tool even if not using a system for development

      python3 # The rebuild script is written in Python and I use it for scripts in other repositories

      nvd # Generate diffs between generations
      pkgs-unstable.nh # Nix helper, not in stable yet but useful to generate diffs before applying changes
      file
      fsearch
      p7zip
      nix-index # Good for searching packages
    ];

    # Enable NTFS support. NOTE: If mounting in Nautilus fails with an error mentioning
    # a bad superblock, try mounting it in the terminal instead.
    boot.supportedFilesystems = ["ntfs"];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.11"; # Did you read the comment?
  };
}
