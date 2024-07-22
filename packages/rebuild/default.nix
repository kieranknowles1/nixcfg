{pkgs}:
pkgs.rustPlatform.buildRustPackage {
  pname = "rebuild";
  version = "2.0.0";
  src = ./.;

  cargoHash = "sha256-E8zazeja//VwXJGaFsIIzSorAOgS3jYdeLzHb1n2qaI=";

  meta = {
    description = "Wrapper for common Nix build workflows";
    longDescription = ''
      Rebuild the system and commit the changes to the repository.

      The commit message contains metadata such as a generation number, the
      builder's hostname, and a diff of packages.
    '';
  };
}
