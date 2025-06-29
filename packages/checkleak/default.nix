{
  self,
  valgrind,
  writeShellApplication,
  target ? "unknown",
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

  meta = {
    inherit (self.lib) license;
    mainProgram = name;
    description = "Check for memory leaks or other issues";
    longDescription = ''
      Wrapper for Valgrind with my preferred defaults,
      and that automatically makes a debug build before
      running.

      ## Usage
      This derivation is useless unless `target` is overridden, this should
      point to the desired build target to test.
    '';
  };
}
