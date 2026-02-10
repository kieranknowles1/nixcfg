{
  self,
  buildScript,
  nushell,
}:
buildScript {
  runtime = nushell;
  name = "foodle";
  src = ./foodle.nu;
  version = "1.0.0";
  meta = {
    inherit (self.lib) license;
    description = "Trilium food diary exporter";
    longDescription = ''
      Export my Trilium-based food diary to CSV, which can then be
      opened by OpenOffice or Excel. This is highly specific to my
      use case and may have limited applicability to others.

      The following data is exported:
      - Date
      - Time
      - Foods
      - Caffeine
      - Medical notes
    '';
  };
}
