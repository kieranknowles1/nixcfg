{rustPlatform}:
rustPlatform.buildRustPackage rec {
  pname = "activate-mutable";
  version = "2.0.3";
  src = ./.;

  cargoHash = "sha256-PKX/nsYkVc4CZ42xrxHgcbGvfilEPDmF9V8Tsf2oKC0=";

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
