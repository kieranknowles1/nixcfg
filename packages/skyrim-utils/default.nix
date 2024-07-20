{pkgs}:
pkgs.rustPlatform.buildRustPackage {
  pname = "skyrim-utils";
  version = "1.2.1";
  src = ./.;

  cargoHash = "sha256-USxe/gdvXyyPhRIdIwD09ajmEg+IWLSbWiMqMaqrDqQ=";

  meta = {
    description = "Utilities for Skyrim debugging";
  };
}
