{
  config,
  lib,
  ...
}: {
  options.custom.carapace = let
    inherit (lib) mkOption types literalExpression;
  in {
    extraCompleters = mkOption {
      type = types.attrsOf types.path;
      description = ''
        Extra completers for carapace in the format
        `name = /path/to/completer.yaml`

        By default, completers are added from the `home.packages` list.
      '';
      default = {};
      example = literalExpression "{ my-command = ./carapace.yaml; }";
    };
  };

  config = let
    cfg = config.custom.carapace;
  in {
    custom.carapace.extraCompleters = lib.trivial.pipe config.home.packages [
      (builtins.filter (p: p.passthru ? carapace))
      (map (p: {
        inherit (p) name;
        value = p.carapace;
      }))
      builtins.listToAttrs
    ];

    programs.carapace = {
      enable = true;
      enableNushellIntegration = true;
    };

    home.file =
      lib.mapAttrs' (name: completer: {
        name = "${config.xdg.configHome}/carapace/specs/${name}.yaml";
        value.source = completer;
      })
      cfg.extraCompleters;
  };
}
