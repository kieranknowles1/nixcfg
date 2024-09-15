# Core configuration needed for any host
{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  self,
  ...
}: let
  # Generate a halper script for activating dev shells in a flake
  devHelper = name: flake: pkgs.writeShellScriptBin name "nix develop ${flake}#$1";
  # Helpers to activate dev shells
  devr = devHelper "devr" "$FLAKE"; # NixOS repository
  dev = devHelper "dev" "."; # Current repository
in {
  options.custom = {
    # Flakes run as pure functions, and as such can't
    # find the repository path on their own. This option
    # is used instead.
    # TODO: Also substitute store references in docs
    repoPath = lib.mkOption {
      description = "Absolute path to the repository on disk";
      type = lib.types.str;
    };

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

    # Apply all of the flake's overlays, as we need them for the system
    nixpkgs.overlays = builtins.attrValues self.overlays;

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs;
      [
        # Helpers to activate dev shells
        dev
        devr
        git # This configuration is in a git repository, so it's an essential tool even if not using a system for development

        nvd # Generate diffs between generations
        pkgs-unstable.nh # Nix helper, not in stable yet but useful to generate diffs before applying changes
        file
        p7zip
      ]
      ++ (lib.optionals (config.custom.deviceType == "desktop") [
        fsearch # Everything clone. GUI only
      ]);

    # Wrapper for `nix run` that detects the source package automatically
    # Prefix command with `,` to use this
    programs.nix-index-database.comma.enable = true;

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

    # This isn't very useful due to its format, especially the options page
    # which struggles to render due to its size.
    documentation.nixos.enable = false;
  };
}
