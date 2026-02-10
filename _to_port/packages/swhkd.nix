{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  udev,
}:
rustPlatform.buildRustPackage rec {
  pname = "swhkd";
  version = "main";
  src = fetchFromGitHub {
    owner = "waycrate";
    repo = "swhkd";
    # main as of 06/12/25
    rev = "ae372e0aff2e87fbfed11d79bcd7fd9ef5f68a60";
    hash = "sha256-EhbRIlI+RsZjPjbYmgu4WzOHJ8udTtlxgJ2kr9iHyd0=";
  };

  nativeBuildInputs = [pkg-config];
  buildInputs = [udev];

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes."sweet-0.4.0" = "sha256-Ky2afQ5HyO1a6YT8Jjl6az1jczq+MBKeuRmFwmcvg6U=";
  };

  meta = {
    license = lib.licenses.bsd2;
    mainProgram = pname;
    description = "Simple Wayland HotKey Daemon";
    longDescription = ''
      A display protocol-independent hotkey daemon made in Rust. swhkd uses an
      easy-to-use configuration system inspired by sxhkd, so you can easily add
      or remove hotkeys.

      It also attempts to be a drop-in replacement for sxhkd, meaning your sxhkd
      config file is also compatible with swhkd.

      Because swhkd can be used anywhere, the same swhkd config can be used
      across Xorg or Wayland desktops, and you can even use swhkd in a TTY.
    '';
    homepage = "https://github.com/waycrate/swhkd";
  };
}
