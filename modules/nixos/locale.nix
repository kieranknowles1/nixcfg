# Locale and timezone settings module
{ ... }:
let
  keymap = "gb";
  locale = "en_GB.UTF-8";
  timezone = "Europe/London";
in
{
  # Set the keyboard layout for X11.
  services.xserver.xkb.layout = keymap;
  # Inherit this for the console.
  console.useXkbConfig = true;

  # Set your time zone.
  time.timeZone = timezone;

  # Select internationalisation properties.
  i18n.defaultLocale = locale;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = locale;
    LC_IDENTIFICATION = locale;
    LC_MEASUREMENT = locale;
    LC_MONETARY = locale;
    LC_NAME = locale;
    LC_NUMERIC = locale;
    LC_PAPER = locale;
    LC_TELEPHONE = locale;
    LC_TIME = locale;
  };
}
