{
  writeShellApplication,
  unzip,
  jq,
  # runtimeEnv doesn't support shell expansions,
  # need absolute paths
  apiKeyFile ? "/home/kieran/.local/share/trilium-data/token",
  destinationDir ? "/home/kieran/Documents/trilium-export",
}:
writeShellApplication rec {
  name = "export-notes";

  runtimeInputs = [
    unzip
    jq
  ];

  runtimeEnv = {
    API_KEY_FILE = apiKeyFile;
    DST_DIR = destinationDir;
  };

  text = builtins.readFile ./export-notes.sh;

  meta = {
    description = "Export notes from Trilium to Git";
    longDescription = ''
      Fetch notes from Trilium as HTML with metadata, then commit the changes to a Git repository.

      Requires that an API key exists at ~/.local/share/trilium-data/token

      Exports to the directory specified by the contents of ~/.local/share/trilium-data/export-dir
    '';

    mainProgram = name;
  };
}
