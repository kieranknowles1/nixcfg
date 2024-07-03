{...}:
{
  # Enable networking
  networking.networkmanager.enable = true;

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
}
