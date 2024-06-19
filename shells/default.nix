{
  pkgs,
  flakePkgs,
}: {
  meta = import ./meta.nix { inherit pkgs flakePkgs; };
}
