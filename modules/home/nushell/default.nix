# Home Manager module to enable Nushell and make it the default shell
# https://nixos.wiki/wiki/Nushell
{
  pkgs,
  config,
  ...
}: let
  defaultMonoFont = config.custom.fonts.defaultMono;

  # NerdFonts is quite large, so only install what we need for the shell
  minifiedNerdFonts = pkgs.nerdfonts.override {
    fonts = [defaultMonoFont];
  };
in {
  programs.nushell = {
    enable = true;

    # Append my custom config to the default
    extraConfig = builtins.readFile ./nushell.nu;
  };

  # Use Carapace to generate completions
  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  # Use Starship as the prompt
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./starship.toml);
  };

  fonts.fontconfig.enable = true;

  # Starship uses icons from NerdFonts
  home.packages = [
    minifiedNerdFonts
  ];
}
