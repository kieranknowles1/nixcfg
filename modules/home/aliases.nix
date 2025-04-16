# Command line aliases
# This is not the same as [[./shortcuts]], that is GUI specific shortcuts
{
  config,
  pkgs,
  lib,
  ...
}: {
  options.custom = let
    inherit (lib) mkOption types;

    # TODO: Should we just read home.shellAliases and skip the extra option?
    aliasType = types.submodule {
      options = {
        exec = mkOption {
          type = types.str;
          description = "The command to run";
        };

        mnemonic = mkOption {
          type = types.str;
          description = ''
            A mnemonic to help remember the alias, in the form [l]etter.

            For example, `[l]azy[g]it` for `lg` -> `lazygit`, or
            `[g]it [d]iff` for `gd` -> `git diff`
          '';
        };
      };
    };
  in {
    aliases = mkOption {
      type = types.attrsOf aliasType;
      description = ''
        A list of aliases to add to the user's shell, along with documentation.

        Acts as a thin wrapper around `home.shellAliases`, the only difference
        being the generated docs.
      '';
      default = {};
    };
  };

  config = let
    cfg = config.custom.aliases;
  in {
    home.shellAliases = builtins.mapAttrs (_name: alias: alias.exec) cfg;

    custom.docs-generate.file."aliases.md" = let
      toDoc = name: alias: "- `${name}`: `${alias.exec}` - ${alias.mnemonic}";
    in {
      description = "Shell Aliases";
      source = pkgs.writeText "aliases.md" ''
        # Shell Aliases

        The following aliases are added to your shell:

        ${builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs toDoc cfg))}
      '';
    };
  };
}
