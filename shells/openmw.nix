{
  mkShell,
  flake
}: let
  inherit (flake) openmw-dev;
in flake.lib.shell.mkShellEx mkShell {
  name = "openmw";

  packages = openmw-dev.buildInputs ++ openmw-dev.nativeBuildInputs;

  CC = "gcc";
  CXX = "g++";

  shellHook = ''
    OPENMW_SRC="$HOME/Documents/src/openmw"

    # cd to the source directory if we're not already there
    # This is horrible, but Bash is horrible
    if ! grep -q "$OPENMW_SRC" <<< "$PWD"; then
      cd "$OPENMW_SRC/build"
    fi
  '';
}
