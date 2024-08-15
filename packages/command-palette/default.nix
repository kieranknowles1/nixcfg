{rustPlatform}:
rustPlatform.buildRustPackage {
  pname = "command-palette";
  version = "2.0.1";
  src = ./.;

  cargoHash = "sha256-sU/9sQDyhLSR4oLRnelQBZEa1KdenigO6FRoTKI/lRw=";

  meta = {
    description = "A simple command palette for running scripts";
    longDescription = ''
      Show a list of options in a dialog box, and run the command associated with
      the selected option, then show the output if any in another dialog box.

      Intended for scripts that are in the midpoint between being run frequently
      enough to warrant a dedicated binding or menu item, and infrequently enough
      to be run from the command line.

      As usual, Rust is overkill, but you can't stop carcinization.

      NOTE: This requires `zenity` to be available in the PATH. 2.0 is incompatible
      with 1.0, as input is now a JSON array, rather than a newline-separated list.
    '';

    mainProgram = "command-palette";
  };
}
