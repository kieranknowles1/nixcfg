# Per-user Firefox settings
{
  hostConfig,
  pkgs,
  lib,
  ...
}: {
  programs.firefox = {
    enable = hostConfig.custom.features.desktop;

    policies = {
      AutofillCreditCardEnabled = false;
      # Updates are managed by Nix
      DisableAppUpdate = true;
      DisableTelemetry = true;
      # Extensions are also managed
      ExtensionUpdate = false;
      # I use Bitwarden for this
      PasswordManagerEnabled = false;
      # Don't use this
      DisablePocket = true;
      DisableFirefoxAccounts = true;
    };

    # Firefix updates frequently and takes a long time to build, so we use the
    # stable channel here.
    package = pkgs.stable.firefox;

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;

      search = {
        default = "Google--";
        # Needed as Firefox overwrites the symlink on startup, which would cause activation to fail
        force = true;
        engines = let
          mkSearch = icon: url: alias: {
            inherit icon;
            urls = lib.singleton {
              template = url;
            };
            definedAliases = [alias];
          };
          mkSearchNixIcon = mkSearch "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          nixosSearch = type: "https://search.nixos.org/${type}?query={searchTerms}&channel=unstable";
        in {
          "Google".metaData.hidden = true;
          # TODO: Use the AIBlock extension when it's available
          "Google--" = {
            urls = lib.singleton {
              # Disable Google's bullshit, use the slightly less bullshit version
              # by removing AI
              template = "https://www.google.com/search?q={searchTerms}&udm=14";
              iconUpdateUrl = "https://www.google.com/favicon.ico";
            };
          };

          "Nix Packages" = mkSearchNixIcon (nixosSearch "packages") "@n";
          "Nix Options" = mkSearchNixIcon (nixosSearch "options") "@no";
          "Home Manager" = mkSearchNixIcon "https://home-manager-options.extranix.com/?query={searchTerms}&release=master" "@hm";
        };
      };

      # To search available extensions, run
      # `nix flake show gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons | grep <search-term>`
      extensions = with pkgs.firefox-addons; [
        bitwarden # Password manager. Available everywhere
        # TODO: Manage config for extensions. How do we export?
        consent-o-matic # Do you consent to being tracked by 1000 companies? No? Too bad.
        darkreader # Midnight flashbang blocker
        privacy-badger # My activity is none of your business
        return-youtube-dislikes # The news doesn't want you to know what other people think
        indie-wiki-buddy # Redirect *.fandom.com to non-fandom wikis
        sponsorblock # This configuration is sponsored by Raid: Sha... oh no, it's spreading
        ublock-origin # HAVE YOU HEARD OF THIS PRODUCT YOU WANT TO BUY? BUY IT NOW
        youtube-shorts-block # No TikTok in this house
      ];

      settings = {
        # Enable extensions automatically
        "extensions.autoDisableScopes" = 0;

        # Disable built-in advertising
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      };
    };
  };

  # Open PDFs in Firefox
  custom.mime.definition = {
    "application/pdf" = {
      defaultApp = "firefox.desktop";
    };
  };
}
