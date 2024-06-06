{
  pkgs
}: {
  clean-skse-cosaves = pkgs.stdenv.mkDerivation rec {
    pname = "clean-skse-cosaves";
    version = "1.0.0";
    src = ./clean-skse-cosaves.py;

    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/${pname}
    '';
  };
}
