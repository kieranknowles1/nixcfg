{
  self,
  buildGodotApp,
}:
buildGodotApp {
  name = "keyboardvis";
  src = ./.;
  version = "1.0.0";
  meta = {
    inherit (self.lib) license;
    description = "Keyboard shortcut visualizer";
    longDescription = ''
      Visualise keyboard shortcuts for better understanding.

      Takes a shortcut layout from the command line (see `example.json`), and
      generates a visual representation of its shortcuts based on held modifiers.

      Only the British keyboard layout is supported, no other layouts are planned
      as I'm British and don't need them.

      Pressing escape will exit with SIGKILL. This is intended behaviour, as it
      takes effect instantly rather than waiting for Godot to exit gracefully.
    '';
  };
}
