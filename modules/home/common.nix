# Options that are used in multiple modules
{
  pkgs,
  config,
  hostConfig,
  lib,
  ...
}: {
  options.custom = let
    inherit (lib) mkOption mkPackageOption types;
  in {
    terminal.package = mkPackageOption pkgs "terminal" {
      # Shorter startup time than kitty
      default = "alacritty";
    };

    repoPath = mkOption {
      description = ''
        Path to the flake repository on disk, relative to the home directory.
      '';
      type = types.path;
      example = "src/nixos";
    };

    fullRepoPath = mkOption {
      description = ''
        (Read-only, set automatically) The full path to the flake repository on disk.
      '';
      type = types.path;
      readOnly = true;
    };

    userDetails = {
      email = mkOption {
        description = "Email address";
        type = types.str;
        example = "bob@example.com";
      };
      firstName = mkOption {
        description = "First name";
        type = types.str;
        example = "Bob";
      };
      surName = mkOption {
        description = "Surname";
        type = types.str;
        example = "Smith";
      };
    };
  };

  config = {
    custom.docs-generate.jsonIgnoredOptions.home = [
      "repoPath"
      "fullRepoPath"
    ];

    # Use the repository path from the host, as long as it's within the home directory
    # This allows the path to be defined either in the host, or in home-manager.
    # As Nix is lazy, the assertion will not be evaluated until the path is used.
    custom.repoPath = let
      inherit (config.home) homeDirectory;
      hostRepoPath = hostConfig.custom.repoPath;

      homeRelativePath =
        if (lib.strings.hasPrefix homeDirectory hostRepoPath)
        then lib.strings.removePrefix homeDirectory hostRepoPath
        else builtins.throw "The repository path must be within the home directory";
    in
      lib.mkDefault homeRelativePath;
    custom.fullRepoPath = "${config.home.homeDirectory}${config.custom.repoPath}";

    # Inherit any overlays from the host to avoid duplication
    nixpkgs.overlays = hostConfig.nixpkgs.overlays;

    home.packages = let
      term =
        lib.optional hostConfig.custom.features.desktop
        config.custom.terminal.package;

      extras = with pkgs; [
        flake.tlro
      ];
    in
      term ++ extras;
    custom.aliases = {
      tldr = {
        exec = "tlro";
        mnemonic = "[t]oo [l]ong [d]idn't [r]ead";
      };
      wtf = {
        exec = "tlro";
        mnemonic = "[w]hat's [t]hat [f]or";
      };
    };

    # Add a command palette entry to rebuild while pulling,
    # this is a fairly common operation for me.
    custom.shortcuts.palette.actions = let
      rebuild = lib.getExe pkgs.flake.rebuild;
    in
      lib.singleton {
        action = [rebuild "--flake" config.custom.fullRepoPath "pull"];
        description = "Update system from remote repository";
        useTerminal = true;
      };
  };
}
