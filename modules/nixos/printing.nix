# Enable printers, I.e., the spawn of the devil or "let's just go to the library"
{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.custom = {
    printing.enable = lib.mkEnableOption "printing";
  };

  config = lib.mkIf config.custom.printing.enable {
    services = {
      printing = {
        enable = true;

        drivers = with pkgs; [
          # Drivers for various printers
          gutenprint
          gutenprintBin
        ];
      };
    };
  };
}
