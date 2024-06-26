# Per-user Firefox settings
# See also: [[../nixos/firefox.nix]]
{
  inputs,
  system,
  ...
}: let
  pkgs-stable = inputs.nixpkgs.legacyPackages.${system};
in {
  programs.firefox = {
    enable = true;

    # Firefix updates frequently and takes a long time to build, so we use the
    # stable channel here.
    package = pkgs-stable.firefox;

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;

      # NOTE: Extensions here still have to be enabled manually
      extensions = with inputs.firefox-addons.packages."${system}"; [
        bitwarden
        darkreader
        privacy-badger
        return-youtube-dislikes
        indie-wiki-buddy
        sponsorblock
        ublock-origin
        youtube-shorts-block
      ];
    };
  };

  # Open PDFs in Firefox
  xdg.mimeApps = {
    enable = true;

    associations.added = {
      "application/pdf" = "firefox.desktop";
    };
  };
}
