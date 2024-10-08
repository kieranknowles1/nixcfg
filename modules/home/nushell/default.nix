# Home Manager module to enable and configure Nushell
# The login shell can only be set by nixos itself, not home-manager.
# A hacky workaround would be to `exec nu` inside bashrc, but I'd rather not do that.
{
  pkgs,
  config,
  hostConfig,
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

    # Give us an environment variable for our flake path
    environmentVariables = {
      FLAKE = "\"${config.custom.fullRepoPath}\"";
    };

    # Append my custom config to the default
    extraConfig = builtins.readFile ./nushell.nu;
  };

  # Use Carapace to generate completions
  programs.carapace = {
    # TODO: Is this necessary?
    enable = hostConfig.custom.features.desktop;
    enableNushellIntegration = true;
  };

  # Use Starship as the prompt
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./starship.toml);
  };

  # Smart cd
  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };

  # fontconfig is not relevant on servers
  fonts.fontconfig.enable = hostConfig.custom.features.desktop;

  # Starship uses icons from NerdFonts
  home.packages = [
    minifiedNerdFonts
  ];
}
