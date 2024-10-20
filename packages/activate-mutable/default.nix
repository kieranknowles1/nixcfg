{rustPlatform}:
rustPlatform.buildRustPackage rec {
  pname = "activate-mutable";
  version = "2.0.0";
  src = ./.;

  cargoHash = "sha256-N5Fu59mM0QwY286TG2sIATU8/mH5/+ZBgzHEko+5CjM=";

  meta = {
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
