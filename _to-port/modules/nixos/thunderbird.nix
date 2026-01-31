# Module to replace GNOME's built in mail client with Thunderbird
{
  pkgs,
  config,
  lib,
  ...
}: {
  config.environment = lib.mkIf config.custom.desktop.enable {
    systemPackages = with pkgs; [
      thunderbird
    ];

    gnome.excludePackages = with pkgs; [
      geary # GNOME's built in mail client
    ];
  };
}
