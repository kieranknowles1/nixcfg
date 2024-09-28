{packagePythonScript}:
packagePythonScript {
  name = "export-blueprints";
  src = ./export-blueprints.py;
  version = "1.0.0";
  meta = {
    description = "Export Factorio blueprints to a directory";
    longDescription = ''
      Export blueprints from ~/.factorio/blueprint-storage.dat to the repository.
      Each blueprint is saved as a separate file, should any fail to be exported,
      a list of failures and their traceback is saved to "errors.txt".

      All paths are hardcoded, as this is intended for this specific repository.

      Requires [factorio-blueprint-decoder](#factorio-blueprint-decoder) to be
      on the PATH.
    '';
  };
}
