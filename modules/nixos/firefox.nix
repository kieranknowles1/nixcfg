# System level Firefox settings
# See also: [[../home/firefox.nix]]
{ pkgs, ...}:
{
  environment.gnome.excludePackages = with pkgs; [
    # GNOME's built-in browser
    epiphany
    # GNOME's document viewer. Firefox does a better job at this
    evince
  ];

  # Install firefox. Extensions are managed by home manager
  programs.firefox = {
    enable = true;

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
  };
}
