{
  pkgs,
  config,
}: let
  isDesktop = config.custom.deviceType == "desktop";

  baseConfig = builtins.fromTOML (builtins.readFile ./config.toml);
  desktopConfig =
    if isDesktop
    then builtins.fromTOML (builtins.readFile ./config-desktop.toml)
    else {};

  # TODO: Put this in our library
  /*
  Deeply merges a list of sets into a single set.
  If a key is present in multiple sets, the values are merged with the following rules:
  - Sets are merged using this function
  - Lists are concatenated
  - All other values are taken from the first set they appear in

  Note: It is assumed that repeated values are of the same type in all sets.

  # Example
  ```nix
  deepMergeSets [
    { a = 1; b = [2]; c = { d = 3; e = 4; }; };
    { a = 2; b = [3]; c = { d = 5; f = 6; }; };
  ] => {
    a = 1; # First value is taken
    b = [2 3]; # Lists are concatenated, in the order the sets are given
    c = {
      d = 3; # Sets are merged recursively, with the same rules
      e = 4; # Unique keys are are kept as-is
      f = 6;
    };
  };
  ```
  */
  deepMergeSets = sets:
    builtins.zipAttrsWith
    (name: values: let
      first = builtins.elemAt values 0;
    in
      if builtins.isAttrs first
      then deepMergeSets values # Recurse into nested sets
      else if builtins.isList first
      then builtins.concatLists values # Concatenate lists
      else first) # We don't want to merge other types, so give the first value precedence
    sets;
in {
  core = {
    displayName = "Kieran";
    isSudoer = true;
    shell = pkgs.nushell;
  };

  home = {
    custom = deepMergeSets [desktopConfig baseConfig];

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "23.11"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    home.packages = [
      # # Adds the 'hello' command to your environment. It prints a friendly
      # # "Hello, world!" when run.
      # pkgs.hello

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    home.file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. If you don't want to manage your shell through Home
    # Manager then you have to manually source 'hm-session-vars.sh' located at
    # either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/kieran/etc/profile.d/hm-session-vars.sh
    #
    home.sessionVariables = {
      # EDITOR = "emacs";
    };
  };
}
