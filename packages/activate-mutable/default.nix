{rustPlatform}:
rustPlatform.buildRustPackage rec {
  pname = "activate-mutable";
  version = "2.0.2";
  src = ./.;

  cargoHash = "sha256-Por64B903VI8s/PJf1llriILic7BJ6DP8aJabdmKlVw=";

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
