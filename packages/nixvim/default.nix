# Nixvim environment
# Using a package rather than a NixOS/home-manager module
# so that I don't have to rebuild everything to change things, can just do
# `nix run .#nixvim`
{
  nixvim,
  system,
  ...
}:
nixvim.legacyPackages.${system}.makeNixvim {
  imports = [
    ./plugins
  ];
}
