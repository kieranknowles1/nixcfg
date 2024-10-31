{
  packagePythonScript,
  flake,
  nano
}:
packagePythonScript {
  name = "export-blueprints";
  src = ./export-blueprints.py;
  version = "2.0.0";
  meta = {
    description = "Export Factorio blueprints to a directory";
    longDescription = ''
      Export blueprints from ~/.factorio/blueprint-storage.dat to the repository.
      Each blueprint is saved as a separate file, should any fail to be exported,
      a list of failures and their traceback is saved to "errors.txt".

      The script is able to decode blueprints from the blueprint-storage.dat file,
      or from a string which must be pasted manually.
    '';
  };

  runtimeInputs = [
    flake.factorio-blueprint-decoder
    nano
  ];
}
