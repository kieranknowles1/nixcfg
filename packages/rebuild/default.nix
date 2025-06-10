{rustPlatform}:
rustPlatform.buildRustPackage {
  pname = "rebuild";
  version = "2.3.0";
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

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
