{
  buildScript,
  python3,
}:
buildScript {
  runtime = python3;
  name = "combine-blueprints";
  src = ./combine-blueprints.py;
  version = "1.0.0";
  meta = {
    description = "Combine a directory of Factorio blueprints into a string";
    longDescription = ''
      Read the files generated by `export-blueprints` and combine them into a string
      that can be pasted into Factorio.
    '';
  };
}
