{
  buildWorkspacePackage,
  self,
  zenity,
}:
buildWorkspacePackage {
  pname = "command-palette";
  src = ./.;

  patchPhase = ''
    # Don't require that zenity is on PATH
    sed -i 's|"zenity"|"${zenity}/bin/zenity"|g' src/dialog.rs
  '';
  meta = {
    inherit (self.lib) license;
    description = "A simple command palette for running scripts";
    longDescription = ''
      Show a list of options in a dialog box, and run the command associated with
      the selected option, then show the output if any in another dialog box.

      Intended for scripts that are in the midpoint between being run frequently
      enough to warrant a dedicated binding or menu item, and infrequently enough
      to be run from the command line.

      As usual, Rust is overkill, but you can't stop carcinization.

      2.0 is incompatible with 1.0, as input is now a JSON array, rather than a
      newline-separated list.
    '';
  };
}
