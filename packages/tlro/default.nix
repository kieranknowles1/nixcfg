{
  src-tldr,
  runCommand,
  mdcat,
  language ? "en",
  platform ? "linux",
  pages ?
    import ./pages.nix {
      inherit src-tldr language platform runCommand;
    },
  writeShellApplication,
}:
writeShellApplication rec {
  name = "tlro";
  runtimeEnv.PAGES = pages;
  runtimeInputs = [
    mdcat
  ];
  text = builtins.readFile ./tlro.sh;

  meta = {
    mainProgram = name;
    description = "Offline only TLDR client";
    longDescription = ''
      Offline only implementation of [tldr pages](https://tldr.sh/)
    '';
  };
}
