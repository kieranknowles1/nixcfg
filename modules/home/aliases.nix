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

        description = mkOption {
          type = types.nullOr types.str;
          description = "A description of the alias. Not always necessary, but can be helpful.";
          default = null;
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
      toDoc = name: alias: let
        description =
          if alias.description == null
          then ""
          else "<br>\n  > ${alias.description}";
      in "- `${name}`: `${alias.exec}`${description}";
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
