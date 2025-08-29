{
  runCommand,
  libheif,
}:
/*
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
source:
runCommand "image.png" { } ''
  ${libheif}/bin/heif-dec "${source}" "$out"
''
