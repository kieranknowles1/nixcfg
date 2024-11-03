{
  writeShellApplication,
  unzip,
  jq,
}:
writeShellApplication rec {
  name = "export-notes";

  runtimeInputs = [
    unzip
    jq
  ];

  text = builtins.readFile ./export-notes.sh;

  meta = {
    description = "Extract a Trilium export to a Git repository";
    longDescription = ''
      Extract a Trilium export passed as an argument to a Git repository,
      and commit the changes with the current date and time.
    '';

    mainProgram = name;
  };
}
