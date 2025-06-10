{
  rustPlatform,
  self,
}:
rustPlatform.buildRustPackage {
  pname = "skyrim-utils";
  version = "1.3.1";
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    inherit (self.lib) license;
    description = "Utilities for Skyrim debugging";
    longDescription = ''
      A collection of utilities for debugging Skyrim and its mods.
      The available utilities are:
      - `clean`: Clean orphaned SKSE co-save files
      - `crash`: Open the most recent crash log
      - `latest`: Open the latest save in ReSaver

      Don't look here for code quality, I made it in a hurry and should have
      used Python instead of Rust.
    '';

    mainProgram = "skyrim-utils";
  };
}
