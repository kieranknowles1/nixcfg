{
  rustPlatform,
  self,
}:
rustPlatform.buildRustPackage rec {
  pname = "openmw-luadata";
  version = "3.0.0";
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    inherit (self.lib) license;
    description = "Read and write OpenMW Lua data files";
    longDescription = ''
      Read and write OpenMW Lua data files, such as those used to store settings.

      Can either read the file to RON (Rust Object Notation) on stdout, or write
      RON to a binary file. RON is used over JSON as it supports structs and
      non-string keys, both needed to represent Lua tables.
    '';

    mainProgram = pname;
  };
}
