# Module to replace GNOME's built in mail client with Thunderbird
{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; [
      thunderbird
    ];

    gnome.excludePackages = with pkgs; [
      geary # GNOME's built in mail client
    ];
  };
}
