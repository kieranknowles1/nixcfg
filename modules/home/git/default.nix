{config, ...}: {
  config = let
    details = config.custom.userDetails;
  in {
    programs.git = {
      # This is stored in a Git repo, so it wouldn't make sense to have a system without Git
      enable = true;

      userName = details.firstName;
      userEmail = details.email;

      # Fancy diffs
      difftastic.enable = true;
      aliases = {
        difft = "diff";
        diffp = "diff --no-ext-diff";
      };

      extraConfig = {
        init.defaultBranch = "main";

        # Don't require "--set-upstream origin <branch>" when pushing a new branch
        push.autoSetupRemote = true;
      };
    };

    # Fancy TUI
    programs.lazygit = {
      enable = true;

      # Lazygit uses YAML, but Nix doesn't support it.
      # https://github.com/SenchoPens/fromYaml is an option, but I
      # don't want to bring in a dependency for something so small.
      settings = builtins.fromTOML (builtins.readFile ./lazygit.toml);
    };

    # Such an essential tool as Git deserves a 2-character command
    # Just like `ls`, `cd`, and `sl`
    custom.aliases = {
      gd = {
        exec = "git diff";
        mnemonic = "[g]it [d]iff";
      };
      lg = {
        exec = "lazygit";
        mnemonic = "[l]azy [g]it";
      };
    };
  };
}
