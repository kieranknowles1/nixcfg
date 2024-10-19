{rustPlatform}:
rustPlatform.buildRustPackage rec {
  pname = "activate-mutable";
  version = "1.0.0";
  src = ./.;

  cargoHash = "sha256-BJ4lyiozi0NVir/Q4LWmHVlNeLs9dqZhnlSid+Oo81s=";

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
