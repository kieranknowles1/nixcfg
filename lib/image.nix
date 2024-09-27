{pkgs}: {
  # Convert a HEIC image to a PNG
  # Takes a path to a HEIC image and returns a path to a PNG image.
  /*
  *
  Convert a HEIC image to a PNG.

  Note that when downloading an iPhone live photo from Immich, two files
  are downloaded with the same extension. The larger is the video, and the
  smaller is the image. This function will only work with the image.

  Also note that PNGs don't compress very well with photos, but a lossy
  conversion would be a bad default.

  # Example
  ```nix
  fromHeif ./path/to/image.heic
  => ./result/output.png
  ```

  # Type
  fromHeif: Path -> Path

  # Arguments
  source :: Path
  : The path to the HEIC image to convert.
  */
  fromHeif = source: let
    # runCommand creates a derivation that runs the given script.
    # It requires us to create a directory at $out, the path to which
    # is returned by the expression and can therefore be used to output
    # files.
    # PNGs don't compress very well with photos, but I don't want a function
    # doing anything lossy without being explicit about it.
    convert = pkgs.runCommand "heif-to-png" {} ''
      mkdir -p $out
      # NOTE: This will need to be changed to heif-dec once 1.18 is on stable
      ${pkgs.libheif}/bin/heif-dec "${source}" "$out/output.png"
    '';
    # We only care about the image, not the directory it's in.
  in "${convert}/output.png";
}
