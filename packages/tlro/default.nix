{
  src-tldr,
  runCommand,
  mdcat,
  language ? "en",
  platform ? "linux",
  # If true, show long options by default otherwise show short options
  # Can be overridden per-invocation using the --short/long-options flag
  longOpts ? true,
  pages ?
    import ./pages.nix {
      inherit src-tldr language platform runCommand;
    },
  writeShellApplication,
}:
writeShellApplication rec {
  name = "tlro";
  runtimeEnv = {
    PAGES = pages;
    VERSION = "1.0.0";
    LONGOPTS = if longOpts then "2" else "1";
  };
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
