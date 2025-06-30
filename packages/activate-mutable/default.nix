{
  rustPlatform,
  self,
}:
rustPlatform.buildRustPackage rec {
  pname = "activate-mutable";
  version = "3.0.3";
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    inherit (self.lib) license;
    description = "Activate mutable files in the home directory";
    longDescription = ''
      Activate mutable files in the home directory that can then be modified
      by programs without needing to rebuild NixOS.

      Can be used either as part of home-manager activation, or standalone to
      bring changes back to the repository.
    '';

    mainProgram = pname;
  };
}
