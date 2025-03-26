{
  src-tldr,
  runCommand,
  mdcat,
  language ? "en",
  platform ? "linux",
  # Show short/long options by default
  # At least one of these must be set
  # Can be overridden per-invocation using the --short/long-options flag
  shortOpts ? true,
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
    SHORTOPTS = shortOpts;
    LONGOPTS = longOpts;
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
