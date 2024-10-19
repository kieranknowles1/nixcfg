{
  writeShellApplication,
  graphviz,
}:
writeShellApplication rec {
  name = "generate-graphs";
  runtimeInputs = [
    graphviz
  ];

  text = builtins.readFile ./generate-graphs.sh;

  meta = {
    description = "Generate SVG graphs from DOT files";
    longDescription = ''
      A script to generate SVG graphs from DOT files. Looks for DOT files in the current directory
      and generates SVG files with the same name, but with the `.svg` extension instead.

      Both the DOT and SVG files should be tracked in version control, this goes against the usual
      advice to not track generated files, but in this case is necessary for images to be displayed
      in documentation.
    '';

    mainProgram = name;
  };
}
