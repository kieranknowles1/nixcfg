{pkgs}:
pkgs.rustPlatform.buildRustPackage {
  pname = "skyrim-utils";
  version = "1.0.0";
  src = ./.;

  cargoHash = "sha256-vqrc+LD7DU/jxLIe6IpoJNa2Pi/w4yPPB+gQMo+JLHs=";
}
