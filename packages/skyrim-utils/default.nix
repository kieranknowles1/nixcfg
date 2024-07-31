{pkgs}:
pkgs.rustPlatform.buildRustPackage {
  pname = "skyrim-utils";
  version = "1.2.2";
  src = ./.;

  cargoHash = "sha256-pkTpzEJYsotC35SlOQ4Plv1uYkXNu3s7bgXFHoiVSvE=";

  meta = {
    description = "Utilities for Skyrim debugging";
  };
}
