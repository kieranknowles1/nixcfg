# Home Manager module to enable and configure Nushell
# The login shell can only be set by nixos itself, not home-manager.
# A hacky workaround would be to `exec nu` inside bashrc, but I'd rather not do that.
{
  config,
  hostConfig,
  lib,
  pkgs,
  ...
}: {
  options.custom = let
    inherit (lib) mkOption types mkPackageOption;
  in {
    fonts = {
      defaultMono = mkPackageOption pkgs.nerd-fonts "dejavu-sans-mono" {
        extraDescription = "Default monospace font";
      };
    };

    extraEnv = mkOption {
      description = ''
        Additional environment variables for shell sessions.

        Note that these do not apply to commands launched outside of an
        interactive shell, such as from the command palette.
      '';
      type = types.attrsOf types.str;
      default = {};
      example = {
        MY_ENV = "value";
      };
    };
  };

  config = let
    cfg = config.custom;
    isDesktop = hostConfig.custom.features.desktop;
  in {
    # TODO: Link to the shell set on the host side, a NuShell specific file isn't the best place for this
    xdg.configFile."default-shell".source = lib.getExe config.programs.nushell.package;

    custom.extraEnv = rec {
      # Point tools to our flake repository
      FLAKE = cfg.fullRepoPath;
      NH_FLAKE = FLAKE;
    };

    custom.mutable.file = {
      "${config.xdg.configHome}/nushell/user-config.nu" = {
        source = ./nushell.nu;
        repoPath = "modules/home/nushell/nushell.nu";
      };
    };

    programs = {
      nushell = {
        # Shell aliases aren't mapped by default, so we need to do it ourselves
        inherit (config.home) shellAliases;

        enable = true;

        # Give us an environment variable for our flake path
        environmentVariables = config.custom.extraEnv;

        # Load my custom config
        extraConfig = "source user-config.nu";
      };

      # Use Starship as the prompt
      starship = {
        enable = true;
        settings = builtins.fromTOML (builtins.readFile ./starship.toml);
      };

      # Smart cd
      zoxide = {
        enable = true;
        enableNushellIntegration = true;
      };
    };

    # Install NerdFonts, as required by Starship and several other programs
    # Not relevant on servers, as SSH fonts are handled by the client
    fonts.fontconfig = {
      enable = isDesktop;

      defaultFonts = {
        monospace = lib.singleton (
          # FIXME: New nixpkgs doesn't list the font name in the package name
          if cfg.fonts.defaultMono == pkgs.nerd-fonts.dejavu-sans-mono
          then "DejaVuSansMono"
          else builtins.throw "Unknown default monospace font"
        );
      };
    };

    home.packages =
      lib.optional isDesktop
      config.custom.fonts.defaultMono;
  };
}
