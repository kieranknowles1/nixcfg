{pkgs}:
pkgs.rustPlatform.buildRustPackage {
  pname = "edit-config";
  version = "4.0.0";
  src = ./.;

  cargoHash = "sha256-PfU/jT3RWmmXluYAESHgW98bH8OwTjaOXP+foCH6hjE=";
}
