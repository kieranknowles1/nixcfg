# Enable printers, I.e., the spawn of the devil or "let's just go to the library"
{
  inputs,
  system,
  ...
}: let
  packagesStable = inputs.nixpkgs.legacyPackages.${system};
in {
  services = {
    printing = {
      enable = true;

      # CUPS seems to be borked on unstable, so let's use the old version
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
