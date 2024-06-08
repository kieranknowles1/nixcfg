{
  pkgs
}: let
  /**
    Package a Python script as a standalone executable.

    A shebang for Python 3 is prepended automatically, although including it in
    the source is recommended to aid in debugging.

    # Arguments
    script :: String : The name of the source file and the output executable.

    version :: String : The version of the script.
   */
  packagePythonScript = script: version: pkgs.stdenv.mkDerivation rec {
    pname = "clean-skse-cosaves";
    inherit version;
    src = ./${pname}.py;

    dontUnpack = true; # This is a text file, unpacking is only applicable to archives
    installPhase = ''
      mkdir -p $out/bin

      src_code=$(cat $src)
      shebang="#!${pkgs.python3}/bin/python3"

      echo "$shebang" > $out/bin/${pname}
      echo "$src_code" >> $out/bin/${pname}
      chmod +x $out/bin/${pname}
    '';
  };
in {
  clean-skse-cosaves = packagePythonScript "clean-skse-cosaves" "1.0.0";
}
