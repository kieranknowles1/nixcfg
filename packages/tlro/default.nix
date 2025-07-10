{
  src-tldr,
  nushell,
  runCommand,
  mdcat,
  sqlite,
  jq,
  self,
  language ? "en",
  platform ? "linux",
  # Show short/long options by default
  # At least one of these must be set
  # Can be overridden per-invocation using the --short/long-options flag
  shortOpts ? true,
  longOpts ? true,
  pages ?
    import ./pages.nix {
      inherit src-tldr nushell runCommand;
    },
  writeShellApplication,
}:
writeShellApplication rec {
  name = "tlro";
  runtimeEnv = {
    PAGES = pages;
    VERSION = "2.0.0";
    LANGUAGE = language;
    PLATFORM = platform;
    SHORTOPTS = shortOpts;
    LONGOPTS = longOpts;
  };
  runtimeInputs = [
    mdcat
    sqlite
    jq
  ];
  text = builtins.readFile ./tlro.sh;

  meta = {
    inherit (self.lib) license;
    mainProgram = name;
    description = "Offline only TLDR client";
    longDescription = ''
      Offline only implementation of [tldr pages](https://tldr.sh/)
    '';
  };
}
