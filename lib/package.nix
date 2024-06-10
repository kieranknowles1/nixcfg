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

    src :: Path | String : The path to the script to package or the script itself

    version :: String : The version of the script.
   */
  packagePythonScript = name: src: version: let
    srcCode = if builtins.isString src then src else builtins.readFile src;
  in pkgs.stdenv.mkDerivation rec {
    pname = name;
    inherit version src;

    # The source code of the script. Exposed as an environment variable for use in the install phase
    SOURCE_CODE = srcCode;

    dontUnpack = true; # This is a text file, unpacking is only applicable to archives
    installPhase = ''
      mkdir -p $out/bin

      shebang="#!${pkgs.python3}/bin/python3"

      echo "$shebang" > $out/bin/${pname}
      echo "$SOURCE_CODE" >> $out/bin/${pname}
      chmod +x $out/bin/${pname}
    '';
  };
}
