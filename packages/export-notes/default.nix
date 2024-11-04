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
    description = "Export notes from Trilium to Git";
    longDescription = ''
      Fetch notes from Trilium as HTML with metadata, then commit the changes to a Git repository.

      Requires that an API key exists at ~/.local/share/trilium-data/token
    '';

    mainProgram = name;
  };
}
