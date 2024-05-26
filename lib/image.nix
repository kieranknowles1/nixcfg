{
  nixpkgs
}: let
  system = "x86_64-linux";
  pkgs = import nixpkgs { inherit system; };
in {
  # Convert a HEIC image to a PNG
  # Takes a path to a HEIC image and returns a path to a PNG image.
  fromHeif = source: let
    # runCommand creates a derivation that runs the given script.
    # It requires us to create a directory at $out, the path to which
    # is returned by the expression and can therefore be used to output
    # files.
    convert = pkgs.runCommand "heif-to-png" {} ''
      mkdir -p $out
      ${pkgs.libheif}/bin/heif-convert ${source} $out/output.png
    '';
  # We only care about the image, not the directory it's in.
  in "${convert}/output.png";
}
