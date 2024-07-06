{pkgs}:
pkgs.rustPlatform.buildRustPackage {
  pname = "skyrim-utils";
  version = "1.1.0";
  src = ./.;

  cargoHash = "sha256-pcwaj+KhvhIS4aWh5C2KH23KcqKcxeVv/8Xcb2wecZQ=";
}
