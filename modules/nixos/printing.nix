# Enable printers, I.e., the spawn of the devil or "let's just go to the library"
# There is nothing but spite to be found in this module
{
  pkgs,
  lib,
  config,
  ...
}: {
  options.custom = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    printing = {
      enable = mkEnableOption "printing";
      scanner.device = mkOption {
        type = types.str;
        default = "escl:https://192.168.1.138:443";
        description = "Scanner device URI";
      };
    };
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

      # Scanners, not quite as demonic as printers
      saned = {
        enable = true;
      };
    };
    hardware.sane = {
      enable = true;
      # Problem: There are 18 competing standards for printing, now it's 19,
      # now it's 20
      extraBackends = [
        pkgs.sane-airscan
      ];
    };
  };
}
