# Enable printers, I.e., the spawn of the devil or "let's just go to the library"
{
  inputs,
  lib,
  system,
  config,
  ...
}: let
  # Force this module to use the stable nixpkgs, even if the system is running unstable
  packagesStable = inputs.nixpkgs.legacyPackages.${system};
in {
  options.custom = {
    printing.enable = lib.mkEnableOption "printing";
  };

  config = lib.mkIf config.custom.printing.enable {
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
    };
  };
}
