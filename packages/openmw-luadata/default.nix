{rustPlatform}:
rustPlatform.buildRustPackage rec {
  pname = "openmw-luadata";
  version = "1.1.0";
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    description = "Read and write OpenMW Lua data files";
    longDescription = ''
      Read and write OpenMW Lua data files, such as those used to store settings.

      Can either read the file to JSON on stdout, or write JSON to a binary file.
    '';

    mainProgram = pname;
  };
}
