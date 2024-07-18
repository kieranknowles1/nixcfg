# Install tools needed for a development environment
{lib, ...}: {
  options.custom = {
    development = {
      enable = lib.mkEnableOption "development tools";
    };
  };
}
