{
  config,
  lib,
  ...
}: {
  options.custom.llm = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "large-language-models";

    webui = {
      port = mkOption {
        description = ''
          The port to run a web interface on.
        '';
        type = types.port;
        # TODO: Some central/automatic way to assign ports
        default = 3000;
      };
    };

    models = mkOption {
      description = ''
        A list of models to install automatically.
        See the [Ollama Library](https://ollama.com/library)
        for a list of available models.
      '';

      type = types.listOf types.str;
      # 8b parameters, comfortably runs on a 12GB GPU
      default = ["llama3"];
    };
  };

  config = let
    cfg = config.custom.llm;
  in
    lib.mkIf cfg.enable {
      warnings = lib.optional (config.services.ollama.acceleration == false) ''
        GPU acceleration for Ollama is disabled. This will be slow.
      '';

      services.ollama = {
        enable = true;
        acceleration =
          if config.custom.nvidia.enable
          then "cuda"
          else false;

        loadModels = cfg.models;
      };

      services.nextjs-ollama-llm-ui = {
        enable = true;
        inherit (cfg.webui) port;
      };
    };
}
