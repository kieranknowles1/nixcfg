{
  self,
  writeShellApplication,
  unzip,
  jq,
  # runtimeEnv doesn't support shell expansions,
  # need absolute paths
  # File containing Trilium's API key. Should be deployed with SOPS
  apiKeyFile ? "/home/kieran/.local/share/trilium-data/token",
  # Base directory to export notes. Must be a Git repository
  # WARN: The subdirectory with name matching the root note will be deleted
  destinationDir ? "/home/kieran/Documents/trilium-export",
  # ID of the note to export with all descendants
  rootNote ? "root",
  # Whether to automatically commit and push changes with a generic message
  autoCommit ? true,
  # Either "markdown" or "html"
  format ? "markdown",
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
    ROOT_NOTE = rootNote;
    AUTO_COMMIT = autoCommit;
    FORMAT = format;
  };

  text = builtins.readFile ./export-notes.sh;

  meta = {
    inherit (self.lib) license;
    description = "Export notes from Trilium to Git";
    longDescription = ''
      Fetch notes from Trilium as HTML with metadata, then commit the changes to a Git repository.

      Requires that an API key exists at ~/.local/share/trilium-data/token

      Exports to the directory specified by the contents of ~/.local/share/trilium-data/export-dir
    '';

    mainProgram = name;
  };
}
