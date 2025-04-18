# Core configuration needed for any host
{
  config,
  pkgs,
  lib,
  self,
  inputs,
  ...
}: {
  options.custom = let
    inherit (lib) mkOption types;
  in {
    # Flakes run as pure functions, and as such can't
    # find the repository path on their own. This option
    # is used instead.
    repoPath = mkOption {
      description = "Absolute path to the repository on disk";
      type = types.str;
    };

    features = let
      mkFeatureOption = name: description:
        mkOption {
          description = "Whether the system is a ${name} and should have ${description} enabled.";
          type = types.bool;
          default = false;
        };
    in {
      desktop = mkFeatureOption "desktop" "a graphical environment";
    };

    hardware = {
      memorySize = mkOption {
        description = "Available RAM, in GB";
        type = types.int;
      };
    };
  };

  config = {
    nix = {
      # Use determinate Nix, for its fancy stuff
      package = inputs.determinate-nix.packages.${pkgs.system}.default;

      # Enable flakes
      settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    # Apply all of the flake's overlays, as we need them for the system
    nixpkgs.overlays = builtins.attrValues self.overlays;

    # Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    # No wait in grub. Can override one-off by holding shift
    boot.loader.timeout = 0;

    # Live dangerously
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs;
      [
        flake.nix-utils
        flake.todos
        ripgrep # Fast search
        nvd # Generate diffs between generations
        nh # Useful to generate diffs before applying changes
        file
        p7zip
      ]
      ++ (lib.optionals config.custom.features.desktop [
        fsearch # Everything clone. GUI only
      ]);

    # Wrapper for `nix run` that detects the source package automatically
    # Prefix command with `,` to use this
    # TODO: Remove nix-index.enable = false once https://github.com/nix-community/nix-index-database/pull/132 is merged
    programs.nix-index.enable = false;
    programs.nix-index-database.comma.enable = true;

    # Enable NTFS support. NOTE: If mounting in Nautilus fails with an error mentioning
    # a bad superblock, try mounting it in the terminal instead.
    boot.supportedFilesystems = ["ntfs"];

    swapDevices = [
      {
        device = "/var/lib/swapfile";
        # 1.5 times RAM size
        size = config.custom.hardware.memorySize * 1536;
      }
    ];

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
