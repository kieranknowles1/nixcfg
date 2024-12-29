{
  buildScript,
  nushell,
  unzip,
  p7zip,
}: buildScript {
  runtime = nushell;
  name = "extract";
  src = ./extract.nu;
  version = "1.0.0";
  runtimeInputs = [
    unzip
    p7zip
  ];
  meta = {
    description = "Generic script to extract various archive formats";
    longDescription = ''
      Extract the contents of an archive file to a directory, automatically detecting
      the format and extraction tool to use.
    '';
  };
}
