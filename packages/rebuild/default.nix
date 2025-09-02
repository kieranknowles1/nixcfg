{
  rustPlatform,
  self,
}:
rustPlatform.buildRustPackage rec {
  pname = "rebuild";
  version = "2.4.1";
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    inherit (self.lib) license;
    description = "Wrapper for common Nix build workflows";
    longDescription = ''
      Rebuild the system and commit the changes to the repository.

      The commit message contains metadata such as a generation number, the
      builder's hostname, and a diff of packages.
    '';

    mainProgram = pname;
  };
}
