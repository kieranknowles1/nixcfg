{
  nixpkgs
}: let
  system = "x86_64-linux";
  pkgs = import nixpkgs { inherit system; };
in {
  /**
    Package a Python script as a standalone executable.

    A shebang for Python 3 is prepended automatically, although including it in
    the source is recommended to aid in debugging.

    Only works with simple scripts, that is, a single file with no dependencies
    outside of the standard library.

    # Arguments
    script :: String : The name of the output executable.

    src :: Path : The path to the script to package.

    version :: String : The version of the script.
   */
  packagePythonScript = name: src: version: pkgs.stdenv.mkDerivation rec {
    pname = name;
    inherit version src;

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
}
