# Enable printers, I.e., the spawn of the devil or "let's just go to the library"
{
  inputs,
  system,
  ...
}: let
  # Force this module to use the stable nixpkgs, even if the system is running unstable
  packagesStable = inputs.nixpkgs.legacyPackages.${system};
in {
  services = {
    printing = {
      enable = true;

      # CUPS seems to be borked on unstable, so let's use the old version
      # When adding a printer, the connection input field is garbage data
      package = packagesStable.cups;

      drivers = with packagesStable; [
        # Drivers for various printers
        gutenprint
        gutenprintBin
      ];
    };

    # Enable resolving *.local hostnames via mDNS
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
    };
  };
}
