# Config for treefmt. This is a Nix module, and as such has all
# the features of one.
# See https://flake.parts/options/treefmt-nix for a list of options
{...}: {
  projectRootFile = "flake.nix";

  programs = {
    alejandra.enable = true; # Nix

    black.enable = true; # Python

    rustfmt.enable = true;
  };
}
