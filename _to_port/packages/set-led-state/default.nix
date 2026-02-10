{
  buildWorkspacePackage,
  self,
}:
buildWorkspacePackage {
  pname = "set-led-state";
  src = ./.;

  meta = {
    inherit (self.lib) license;
    description = "A simple CLI tool to set the state of an LED";
    longDescription = ''
      Turn an LED, such as caps lock, num lock, or scroll lock, on or off.

      Is writing this in Rust overkill? Yes. But you can't stop me.
    '';
  };
}
