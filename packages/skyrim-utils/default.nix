{rustPlatform}:
rustPlatform.buildRustPackage {
  pname = "skyrim-utils";
  version = "1.2.2";
  src = ./.;

  cargoHash = "sha256-pkTpzEJYsotC35SlOQ4Plv1uYkXNu3s7bgXFHoiVSvE=";

  meta = {
    description = "Utilities for Skyrim debugging";
    longDescription = ''
      A collection of utilities for debugging Skyrim and its mods.
      The available utilities are:
      - `clean`: Clean orphaned SKSE co-save files
      - `crash`: Open the most recent crash log
      - `latest`: Open the latest save in ReSaver
    '';

    mainProgram = "skyrim-utils";
  };
}
