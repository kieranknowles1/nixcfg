# Module to install Nvidia drivers
{ config, lib, ... }:
{
  options = {
    custom.nvidia.enable = lib.mkEnableOption "Nvidia drivers";
  };

  config = lib.mkIf config.custom.nvidia.enable {
    # This may not cover everything, but it gets Skyrim running and that's good enough for now.
    # https://nixos.wiki/wiki/Nvidia
    hardware.opengl = {
      enable = true;
      driSupport32Bit = true;
    };
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
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
  };
}
