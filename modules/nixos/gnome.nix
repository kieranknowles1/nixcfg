{ config, pkgs, ...}:
{
  # TODO: Move rest of GNOME here

  # Remove unneeded packages
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];
}
