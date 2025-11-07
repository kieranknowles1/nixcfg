{
  config,
  hostConfig,
  pkgs,
  lib,
  ...
}: {
  config = let
    details = config.custom.userDetails;

    inherit (hostConfig.custom.ssh) keyOwners;
  in {
    # Fancy diffs
    programs.difftastic = {
      enable = true;
      # Use as default diff for git
      git.enable = true;
    };
    
    programs.git = {
      # This is stored in a Git repo, so it wouldn't make sense to have a system without Git
      enable = true;

      # Sign commits with SSH
      signing = {
        format = "ssh";
        key = "~/.ssh/id_ed25519.pub";
        signByDefault = true;
      };

      settings = {
        user.name = details.firstName;
        user.email = details.email;
        
        init.defaultBranch = "main";

        # Save a bit of disk space
        core.compression = 9;

        # Don't require "--set-upstream origin <branch>" when pushing a new branch
        push.autoSetupRemote = true;

        # If pulling while behind, rebase instead of merging
        pull.rebase = true;

        aliases = {
          difft = "diff";
          diffp = "diff --no-ext-diff";
        };
        
        # Shortcuts for URLs
        url = {
          "git@github.com:kieranknowles1/".insteadOf = "kk:";
          "git@github.com:".insteadOf = "gh:";
          "git@gitlab.com:".insteadOf = "gl:";
        };

        # Recurse into untracked directories - these need to be resolved by either tracking or ignoring them
        status.showUntrackedFiles = "all";

        gpg.ssh.allowedSignersFile = let
          # Owner can sign on behalf of themselves and no one else
          signerEntry = owner: key: "${owner} ${key}";

          ownerKeys = builtins.mapAttrs (owner: map (signerEntry owner)) keyOwners;
          keyEntries = lib.lists.flatten (builtins.attrValues ownerKeys);
        in
          builtins.toPath (pkgs.writeText "allowed-signers" (
            builtins.concatStringsSep "\n" keyEntries
          ));
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
    custom.aliases = lib.mkMerge [
      {
        gd = {
          exec = "git diff";
          mnemonic = "[g]it [d]iff";
        };
      }
      (lib.mkIf config.programs.lazygit.enable {
        lg = {
          exec = "lazygit";
          mnemonic = "[l]azy [g]it";
        };
      })
    ];
  };
}
