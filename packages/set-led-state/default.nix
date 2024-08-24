{rustPlatform}:
rustPlatform.buildRustPackage rec {
  pname = "set-led-state";
  version = "1.0.0";
  src = ./.;

  cargoHash = "sha256-t0sqN6jrq//lQa0Thp1GMoIoJee5ycVt6/WM0vLlEho=";

  meta = {
    description = "A simple CLI tool to set the state of an LED";
    longDescription = ''
      Turn an LED, such as caps lock, num lock, or scroll lock, on or off.

      Is writing this in Rust overkill? Yes. But you can't stop me.
    '';

    mainProgram = pname;
  };
}
