# TODO: Resaver is on GitHub now, no need for this workaround, just build it from source
{
  writeShellApplication,
  makeDesktopItem,
  symlinkJoin,
  lib,
  jq,
  jdk21,
}:
let
  resaver = writeShellApplication {
    name = "resaver";
    runtimeInputs = [
      jq
      jdk21
    ];

    text = builtins.readFile ./resaver.sh;
  };

  desktopItem = makeDesktopItem {
    name = "resaver";
    desktopName = "ReSaver";
    comment = "Skyrim and Fallout 4 savegame editor";
    exec = "${lib.getExe resaver} %u";
  };
in
symlinkJoin {
  name = "resaver";
  paths = [
    resaver
    desktopItem
  ];

  meta = {
    license = lib.licenses.asl20;
    description = "Skyrim and Fallout 4 savegame editor";
    longDescription = ''
      A savegame editor for Skyrim and Fallout 4, wrapped to be fetched automatically
      from Nexus Mods with an API key.

      The first time the script is run, it will download the JAR file from Nexus Mods. Subsequent
      calls will use the cached file.

      # Prerequisites
      The API key of a premium Nexus Mods account must be stored at `~/.config/sops-nix/secrets/nexusmods/apikey`.
    '';

    mainProgram = resaver.name;
  };
}
