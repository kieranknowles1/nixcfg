{pkgs, lib, ...}: {
  config = {
    # Enable networking
    networking = {
      networkmanager.enable = true;
      # This is handled by NetworkManager
      wireless.enable = false;

      # Disable plugins we don't use
      networkmanager.plugins = lib.mkForce [
        # networkmanager-fortisslvpn # VPN plugin for Fortinet
        # networkmanager-iodine # Tunnel to get through firewalls
        # networkmanager-l2tp # Another VPN plugin
        # networkmanager-openconnect # Cisco VPN plugin
        # networkmanager-openvpn # Another VPN plugin
        # networkmanager-vpnc # Another VPN plugin
        # networkmanager-sstp # What do you know, another VPN
      ];
    };

    # Enable resolving *.local hostnames via mDNS
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;

      # Expose our hostname to the network
      publish = {
        enable = true;

        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
    };
  };
}
