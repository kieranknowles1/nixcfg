{
  config,
  lib,
  ...
}: {
  options.custom.llm = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "Large Language Model";

    models = mkOption {
      description = ''
        A list of models to install automatically.
        See the [Ollama Library](https://ollama.com/library)
        for a list of available models.
      '';

      type = types.listOf types.str;
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
    };
}
