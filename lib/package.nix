{
  pkgs
}: {
  /**
    Package a Python script as a standalone executable.

    A shebang for Python 3 is prepended automatically, although including it in
    the source is recommended to aid in debugging.

    Only works with simple scripts, that is, a single file with no dependencies
    outside of the standard library.

    # Arguments
    script :: String : The name of the output executable.

    src :: String : The path to the script to package or the script itself

    version :: String : The version of the script.
   */
  packagePythonScript = name: src: version: pkgs.stdenv.mkDerivation rec {
    pname = name;
    inherit version src;

    dontUnpack = true; # This is a text file, unpacking is only applicable to archives
    installPhase = ''
      mkdir -p $out/bin

      shebang="#!${pkgs.python3}/bin/python3"

      echo "$shebang" > $out/bin/${pname}
      cat $src >> $out/bin/${pname}
      chmod +x $out/bin/${pname}
    '';
  };
}
