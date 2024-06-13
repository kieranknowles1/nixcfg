# Enable printers, I.e., the spawn of the devil or "let's just go to the library"
{
  pkgs,
  ...
}: {
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
}
