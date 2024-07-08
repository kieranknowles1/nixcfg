{pkgs}:
pkgs.rustPlatform.buildRustPackage {
  pname = "skyrim-utils";
  version = "1.2.0";
  src = ./.;

  cargoHash = "sha256-LuEfA3yj47UI66kALNgHVUvLv6chQLYKj6RiToTa2MY=";
}
