# Enable printers, I.e., the spawn of the devil or "let's just go to the library"
{
  pkgs,
  lib,
  config,
  ...
}: {
  options.custom = {
    printing.enable = lib.mkEnableOption "printing";
  };

  config = lib.mkIf config.custom.printing.enable {
    services = {
      printing = {
        enable = true;

        # CUPS seems to be borked on unstable, so let's use the old version
        # When adding a printer, the connection input field is garbage data
        # Printing is cursed enough as it is, so let's not take any chances
        package = pkgs.stable.cups;

        drivers = with pkgs.stable; [
          # Drivers for various printers
          gutenprint
          gutenprintBin
        ];
      };
    };
  };
}
