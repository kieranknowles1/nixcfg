{
  nvf,
  pkgs,
}:
(nvf.lib.neovimConfiguration {
  inherit pkgs;

  modules = [
    ./theme.nix
  ];
}).neovim
