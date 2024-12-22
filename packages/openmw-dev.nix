{
  pkgs,
  openmw,
  system,
}: let
  # This could be a flake input, but it would take a long time to compile
  # when upgrading inputs
  latestSrc = pkgs.fetchFromGitLab {
    owner = "kieranjohn1";
    repo = "openmw";
    # My fork, based on master as of 25-09-2024
    rev = "4a087abb1def76f96873eccb4d4eeac5ffd9c62c";
    hash = "sha256-KAVCbBHp69cmZP1LnWowH+LpzFxQrZXtmQXkJWURjPY=";
  };

  devPkg = openmw.packages.${system}.openmw-dev;
in
  # TODO: Move to our overlay
  devPkg.overrideAttrs (_oldAttrs: {
    src = latestSrc;
  })
