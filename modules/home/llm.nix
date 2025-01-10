{
  hostConfig,
  lib,
  ...
}: {
  config = let
    cfg = hostConfig.custom.llm;
  in
    lib.mkIf cfg.enable {
      custom.shortcuts.palette.actions = lib.singleton {
        action = ["xdg-open" "http://localhost:${toString cfg.webui.port}"];
        description = "View LLM web interface";
      };
    };
}
