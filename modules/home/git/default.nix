{
  config,
  hostConfig,
  pkgs,
  ...
}: {
  config = let
    details = config.custom.userDetails;

    inherit (hostConfig.custom.ssh) authorizedKeys;
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

      # Sign commits with SSH
      signing = {
        format = "ssh";
        key = "~/.ssh/id_ed25519.pub";
        signByDefault = true;
      };

      extraConfig = {
        init.defaultBranch = "main";

        # Save a bit of disk space
        core.compression = 9;

        # Don't require "--set-upstream origin <branch>" when pushing a new branch
        push.autoSetupRemote = true;

        # If pulling while behind, rebase instead of merging
        pull.rebase = true;

        # Shortcuts for URLs
        url = {
          "git@github.com:kieranknowles1/".insteadOf = "kk:";
          "git@github.com:".insteadOf = "gh:";
          "git@gitlab.com:".insteadOf = "gl:";
        };

        # Recurse into untracked directories - these need to be resolved by either tracking or ignoring them
        status.showUntrackedFiles = "all";

        # TODO: Filter who each key can sign on behalf of. Currently, anyone can sign anything.
        gpg.ssh.allowedSignersFile = let
          signerEntry = keyFile: "* ${builtins.readFile keyFile}";
        in
          builtins.toPath (pkgs.writeText "allowed-signers" (
            # TODO: Recognise any known key, even if it isn't allowed to SSH
            builtins.concatStringsSep "\n" (map signerEntry authorizedKeys)
          ));
      };
    };

    # Fancy TUI
    programs.lazygit = {
      enable = hostConfig.custom.features.extras;

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
