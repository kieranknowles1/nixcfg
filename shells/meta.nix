{
  pkgs,
  flakePkgs
}: pkgs.mkShellNoCC {
  packages = [
    flakePkgs.factorio-blueprint-decoder
  ];

  shellHook = "nu";
}
