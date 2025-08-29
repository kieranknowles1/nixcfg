{
  writeShellApplication,
  ripgrep,
  self,
}:
writeShellApplication rec {
  name = "todos";

  runtimeInputs = [ ripgrep ];

  text = builtins.readFile ./todos.sh;

  meta = {
    inherit (self.lib) license;
    description = "List all TODOs in a directory";
    longDescription = ''
      Recursively search a directory for TODO comments in files.

      Output is sorted by modification time, most recent last. And
      is not paginated.

      Run with `--help` for additional information.
    '';

    mainProgram = name;
  };
}
