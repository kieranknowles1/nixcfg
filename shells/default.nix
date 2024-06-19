{
  pkgs,
  flakePkgs,
}: {
  # TODO: Replace all our "config.custom.development" options with dev shells.
  # Need some way to provision code extensions and other things.
  meta = import ./meta.nix { inherit pkgs flakePkgs; };
}
