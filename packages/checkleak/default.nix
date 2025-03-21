{
  valgrind,
  writeShellApplication,
  target ? "CSC8508-1", # TODO: More sensible default
  suppressions ? [./valgrind-ignore.supp],
}:
writeShellApplication rec {
  name = "checkleak";

  runtimeInputs = [
    valgrind
  ];

  runtimeEnv = {
    TARGET = target;
    SUPPRESSIONS = map (s: "--suppressions=${s}") suppressions;
  };

  text = builtins.readFile ./checkleak.sh;

  # TODO: Add to cmake shell
  meta = {
    mainProgram = name;
    description = "Check for memory leaks or other issues";
    longDescription = ''
      Wrapper for Valgrind with my preferred defaults,
      and that automatically makes a debug build before
      running.
    '';
  };
}
