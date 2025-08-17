# Module to include generated documentation for the flake and its options
{
  lib,
  config,
  hostConfig,
  ...
}: {
  options.custom.docs-generate = let
    inherit (lib) mkEnableOption;
  in {
    install = mkEnableOption "install generated documentation for the flake and its options.";
  };

  config = let
    cfg = config.custom.docs-generate;
  in
    lib.mkMerge [
      {
        # Inherit host-wide pages
        custom.docs-generate.file = hostConfig.custom.docs-generate.file;
      }
      (lib.mkIf cfg.install {
        custom.shortcuts.palette.actions = lib.singleton {
          description = "View documentation";
          # These are built from markdown where the convention is `readme.md` rather than `index.html`
          action = ["xdg-open" "${cfg.build.combined.html}/index.html"];
        };

        home.file."${config.custom.repoPath}/docs/generated" = {
          source = "${cfg.build.generated}/generated";
          recursive = true;
        };
      })
    ];
}
