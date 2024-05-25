{ config, lib, pkgs, ... }:
{
  options = {
    custom.office.enable = lib.mkEnableOption "office suite";
  };

  config = lib.mkIf config.custom.office.enable {
    environment.systemPackages = with pkgs; [
      libreoffice-qt
      # Needed for spell check
      hunspell
      hunspellDicts.en_GB-ize
    ];
  };
}
