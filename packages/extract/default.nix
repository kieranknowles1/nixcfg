{
  writeShellApplication,
  makeDesktopItem,
  symlinkJoin,
  lib,
  p7zip,
  unzip,
  unrar-free,
}: let
  extract = writeShellApplication rec {
    name = "extract";
    runtimeInputs = [
      p7zip
      unzip
      unrar-free
    ];
    text = builtins.readFile ./extract.sh;

    meta = {
      mainProgram = name;
      description = "Extract files from archives";
      longDescription = ''
        Extract archives of any type, automatically detecting their type.

        Currently supports the following formats:
        - 7zip
        - rar
        - zip
      '';
    };
  };

  desktopItem = makeDesktopItem {
    inherit (extract) name;
    desktopName = "Extract";
    exec = "${lib.getExe extract} %F";
    terminal = true;
    mimeTypes = [
      "application/x-7z-compressed"
      "application/zip"
      "application/vnd.rar"
    ];
  };
in
  symlinkJoin {
    inherit (extract) name meta;
    paths = [extract desktopItem];
  }
