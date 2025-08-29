# Per-user Firefox settings
{
  lib,
  config,
  hostConfig,
  pkgs,
  ...
}:
{
  options.custom.firefox =
    let
      inherit (lib) mkOption types literalExpression;
    in
    {
      extraExtensions = mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = "Additional extensions to install";
        example = literalExpression ''
          with pkgs.firefox-addons; [
            ublock-origin
          ];
        '';
      };
    };

  config =
    let
      cfg = config.custom.firefox;
    in
    lib.mkIf hostConfig.custom.features.desktop {
      programs.firefox = {
        enable = true;

        policies = {
          AutofillCreditCardEnabled = false;
          # Updates are managed by Nix
          DisableAppUpdate = true;
          DisableTelemetry = true;
          # Extensions are also managed
          ExtensionUpdate = false;
          # My data is none of your business
          EnableTrackingProtection = {
            Value = true;
            Cryptomining = true;
            Fingerprinting = true;
            EmailTracking = true;
            Locked = true;
          };
          # I use Bitwarden for this
          PasswordManagerEnabled = false;
          # Don't use this
          DisablePocket = true;
          DisableFirefoxAccounts = true;
        };

        profiles.default = {
          id = 0;
          name = "default";
          isDefault = true;

          # To search available extensions, run
          # `nix flake show gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons | grep <search-term>`
          extensions =
            with pkgs.firefox-addons;
            [
              bitwarden # Password manager. Available everywhere
              # TODO: Manage config for extensions. How do we export?
              consent-o-matic # Do you consent to being tracked by 1000 companies? No? Too bad.
              darkreader # Midnight flashbang blocker
              privacy-badger # My activity is none of your business
              return-youtube-dislikes # The news doesn't want you to know what other people think
              indie-wiki-buddy # Redirect *.fandom.com to non-fandom wikis
              sponsorblock # This configuration is sponsored by Raid: Sha... oh no, it's spreading
              # TODO: Auto install https://github.com/laylavish/uBlockOrigin-HUGE-AI-Blocklist
              ublock-origin # HAVE YOU HEARD OF THIS PRODUCT YOU WANT TO BUY? BUY IT NOW
              youtube-shorts-block # No TikTok in this house
            ]
            ++ cfg.extraExtensions;

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
    };
}
