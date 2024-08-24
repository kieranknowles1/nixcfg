{rustPlatform}:
rustPlatform.buildRustPackage rec {
  pname = "openmw-luadata";
  version = "1.0.0";
  src = ./.;

  cargoHash = "sha256-Y6LnDCTTdgzhh50VFqheD6BkUfdc7L05x47vx+xldV8=";

  meta = {
    description = "Read and write OpenMW Lua data files";
    longDescription = ''
      Read and write OpenMW Lua data files, such as those used to store settings.

      Can either read the file to JSON on stdout, or write JSON to a binary file.
    '';

    mainProgram = pname;
  };
}
