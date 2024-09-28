{
  packagePythonScript,
  src-factorio-blueprint-decoder,
}:
packagePythonScript {
  name = "factorio-blueprint-decoder";
  src = "${src-factorio-blueprint-decoder}/decode";
  version = "unstable";
  meta = {
    description = "Decode a Factorio blueprint storage file";
    longDescription = ''
      Decode a Factorio blueprint storage file into plain JSON on stdout.
      This should be considered highly unstable, and may break at any time
      or for any reason, but is designed to error out instead of producing
      invalid output.
    '';

    homepage = "https://github.com/kieranknowles1/factorio-blueprint-decoder/tree/turret_fix";
  };
}
