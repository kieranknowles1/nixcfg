{pkgs}:
pkgs.rustPlatform.buildRustPackage {
  pname = "rebuild";
  version = "2.0.0";
  src = ./.;

  cargoHash = "sha256-E8zazeja//VwXJGaFsIIzSorAOgS3jYdeLzHb1n2qaI=";
}
