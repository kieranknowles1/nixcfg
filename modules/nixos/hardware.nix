# Module to install Nvidia drivers
{
  config,
  lib,
  ...
}: {
  options.custom.hardware = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    nvidia.enable = mkEnableOption "Nvidia drivers";

    memorySize = mkOption {
      description = "Available RAM, in GB";
      type = types.int;
    };
  };

  config = let
    cfg = config.custom.hardware;
    nvidiaOnly = lib.mkIf cfg.nvidia.enable;
  in {
    # See https://nixos.wiki/wiki/Nvidia
    # TODO: Should this be enabled on all desktops?
    hardware.graphics = nvidiaOnly {
      enable = true;
      enable32Bit = true;
    };
    services.xserver.videoDrivers = lib.optional cfg.nvidia.enable "nvidia";
    hardware.nvidia = nvidiaOnly {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      # The open source drivers are not as good as the proprietary ones and don't seem to work with Wayland.
      # NOTE: Even though I'm using Wayland, I still consider it experimental with Nvidia. Intel integrated works
      # just fine though and I'd like to have the same on all my machines.
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    swapDevices = [
      {
        device = "/var/lib/swapfile";
        # 1.5 times RAM size
        size = config.custom.hardware.memorySize * 1536;
      }
    ];
  };
}
