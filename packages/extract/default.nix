{
  writeShellApplication,
  p7zip,
  unzip,
  unrar-free,
}:
writeShellApplication rec {
  name = "extract";
  runtimeInputs = [
    p7zip
    unzip
    unrar-free
  ];
  # TODO: Make this the default app to extract archives, replacing Ark
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
}
