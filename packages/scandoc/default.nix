{
  self,
  buildScript,
  nushell,
  paperlessUrl ? "http://localhost:28981",
  paperlessTokenFile ? "/run/secrets/paperless_token",
}:
buildScript {
  runtime = nushell;
  name = "scandoc";
  src = ./scandoc.nu;
  version = "1.0.0";

  meta = {
    inherit (self.lib) license;
    description = "Scan paper documents into Paperless";
    longDescription = ''
      Scan multi-page documents based on a user-provided page count,
      and automatically upload them to a Paperless NGX instance.
    '';
  };

  runtimeEnv = {
    PAPERLESS_URL = paperlessUrl;
    PAPERLESS_API_KEY_FILE = paperlessTokenFile;
  };
}
