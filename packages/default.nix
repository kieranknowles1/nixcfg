{
  pkgs
}: let
  /**
    Package a Python script as a standalone executable.

    A shebang for Python 3 is prepended automatically, although including it in
    the source is recommended to aid in debugging.

    Only works with simple scripts, that is, a single file with no dependencies
    outside of the standard library.

    # Arguments
    script :: String : The name of the source file and the output executable.

    version :: String : The version of the script.
   */
  packagePythonScript = script: version: pkgs.stdenv.mkDerivation rec {
    pname = script;
    inherit version;
    # The source file is in the same directory as the derivation, convert it to a relative path
    src = ./. + "/${script}.py";

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

  edit-config = packagePythonScript "edit-config" "1.0.0";
}
