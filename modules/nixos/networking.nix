{
  config,
  lib,
  ...
}: {
  options.custom = {
    wireless.enable = lib.mkEnableOption "wireless networking";
  };

  config = {
    # Enable networking
    networking = {
      networkmanager.enable = true;
      wireless.enable = config.custom.wireless.enable;
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
