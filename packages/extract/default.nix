{
  self,
  writeShellApplication,
  makeDesktopItem,
  symlinkJoin,
  lib,
  libnotify,
  p7zip,
  unzip,
  unrar-free,
  gnutar,
}: let
  extract = writeShellApplication rec {
    name = "extract";
    runtimeInputs = [
      libnotify
      p7zip
      unzip
      unrar-free
      gnutar
    ];
    text = builtins.readFile ./extract.sh;

    meta = {
      inherit (self.lib) license;
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
    exec = "${lib.getExe extract} --notify %F";
    mimeTypes = [
      "application/x-compressed-tar"
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
