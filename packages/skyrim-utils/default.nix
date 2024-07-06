{pkgs}:
pkgs.rustPlatform.buildRustPackage {
  pname = "skyrim-utils";
  version = "1.0.0";
  src = ./.;

  cargoHash = "sha256-vBHdqKTWxPnvRL7jKwvjBS/ccHDikT7hqWdRF0tGwXI=";
}
