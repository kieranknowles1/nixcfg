# Per-user Firefox settings
# See also: [[../nixos/firefox.nix]]
{
  hostConfig,
  inputs,
  system,
  ...
}: let
  isDesktop = hostConfig.custom.deviceType == "desktop";

  pkgs-stable = inputs.nixpkgs.legacyPackages.${system};
in {
  programs.firefox = {
    enable = isDesktop;

    policies = {
      AutofillCreditCardEnabled = false;
      # Updates are managed by Nix
      DisableAppUpdate = true;
      DisableTelemetry = true;
      # Extensions are also managed
      ExtensionUpdate = false;
      # I use Bitwarden for this
      PasswordManagerEnabled = false;
    };

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
    enable = isDesktop;

    associations.added = {
      "application/pdf" = "firefox.desktop";
    };
  };
}
