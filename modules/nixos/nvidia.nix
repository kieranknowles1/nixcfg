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
      driSupport = true;
      driSupport32Bit = true;
    };
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
