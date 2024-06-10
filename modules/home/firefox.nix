# Per-user Firefox settings
# See also: [[../nixos/firefox.nix]]
{ inputs, system, ... }:

{
  programs.firefox = {
    enable = true;

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
