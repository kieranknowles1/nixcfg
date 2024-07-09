{pkgs, config, lib, ...}:
{
  # TODO: Maybe allow multiple editors to be installed at the same time
  config = lib.mkIf config.custom.editor == "neovim" {
    home.packages = with pkgs; [
      neovim
    ];
  }
}
