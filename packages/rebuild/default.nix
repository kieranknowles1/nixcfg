{rustPlatform}:
rustPlatform.buildRustPackage {
  pname = "rebuild";
  version = "2.2.0";
  src = ./.;

  cargoHash = "sha256-aGNx9ZiN+t9jBmg7TvxgCyIQtXP5Mv7CfDp2lwTd1zs=";

  meta = {
    description = "Wrapper for common Nix build workflows";
    longDescription = ''
      Rebuild the system and commit the changes to the repository.

      The commit message contains metadata such as a generation number, the
      builder's hostname, and a diff of packages.
    '';

    mainProgram = "rebuild";
  };
}
