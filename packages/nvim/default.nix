{
  nvf,
  pkgs,
}:
(nvf.lib.neovimConfiguration {
  inherit pkgs;

  modules = [
    ./editor.nix
    ./lsp.nix
    ./theme.nix
  ];
}).neovim
