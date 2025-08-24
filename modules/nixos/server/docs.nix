{
  lib,
  config,
  ...
}: {
  options.custom.server.docs = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "hosted docs";

    subdomain = mkOption {
      type = types.str;
      default = "docs";
      description = "The subdomain to use for the hosted docs";
    };
  };

  config = let
    cfg = config.custom.server;
    cfgd = cfg.docs;
  in
    lib.mkIf cfg.enable {
      custom.server = {
        subdomains.${cfgd.subdomain} = {
          root = config.custom.docs-generate.build.combined.html;
          cache.enable = true;
        };
        homepage.services = lib.singleton {
          group = "Meta";
          name = "Docs";
          description = "Repository documentation";
          icon = "mdi-book-open-variant";
          href = "https://${cfgd.subdomain}.${cfg.hostname}";
        };
      };
    };
}
