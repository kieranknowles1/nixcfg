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
    cfg = config.custom.server.docs;
  in
    lib.mkIf cfg.enable {
      custom.server.subdomains.${cfg.subdomain} = {
        # HACK: Ideally we'd generate docs host-side. All generic pages can be
        # done so and machine-specific ones don't matter for a server.
        # Probably want a builder to create docs then make home-manager extend it.
        root = config.home-manager.users.kieran.custom.docs-generate.build.combined.html;
      };
    };
}
