{
  writeShellApplication,
  jq,
  jdk21,
}:
writeShellApplication rec {
  name = "resaver";
  runtimeInputs = [
    jq
    jdk21
  ];

  text = builtins.readFile ./resaver.sh;

  meta = {
    description = "Skyrim and Fallout 4 savegame editor";
    longDescription = ''
      A savegame editor for Skyrim and Fallout 4, wrapped to be fetched automatically
      from Nexus Mods with an API key.

      The first time the script is run, it will download the JAR file from Nexus Mods. Subsequent
      calls will use the cached file.

      # Prerequisites
      The API key of a premium Nexus Mods account must be stored at `~/.config/sops-nix/secrets/nexusmods/apikey`.
    '';

    mainProgram = name;
  };
}
