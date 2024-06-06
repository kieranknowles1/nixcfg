{
  config,
  lib,
  ...
}: {
  # TODO: Configure neovim
  config = lib.mkIf (config.custom.development.editor == "neovim") {
    programs.neovim = {
      enable = true;
    };
  };
}
