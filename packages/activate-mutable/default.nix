{rustPlatform}:
rustPlatform.buildRustPackage rec {
  pname = "activate-mutable";
  version = "2.0.1";
  src = ./.;

  cargoHash = "sha256-pnlGid7fv6T6hfwRR48eEuQSXIm5hysv1hQEjJD3Tqo=";

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
