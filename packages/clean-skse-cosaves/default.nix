{pkgs}:
pkgs.rustPlatform.buildRustPackage {
  pname = "clean-skse-cosaves";
  version = "2.0.0";
  src = ./.;

  cargoHash = "sha256-FBGQKvvvV6pQpwD2P13YtFr5CH6K65PH7nDrIJDCEUc=";
}
