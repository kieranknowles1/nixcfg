{
  cargo,
  rustc,
  mkShell,
  openssl,
  pkg-config,
  rust,
  flake,
  lib,
  xorg,
  libGL,
  libxkbcommon,
  wayland,
}:
flake.lib.shell.mkShellEx mkShell {
  name = "rust";

  # Packages to put on the PATH
  packages = [
    cargo
    rustc
    pkg-config # Needed for rust-analyzer
  ];

  # Libraries needed for building
  buildInputs = [
    openssl
  ];

  # Rust-analyzer requires the standard library's source code to give
  # completions.
  RUST_SRC_PATH = "${rust.packages.stable.rustPlatform.rustLibSrc}";

  # Required for eframe apps to work
  LD_LIBRARY_PATH = lib.makeLibraryPath [
    libGL
    libxkbcommon
    wayland
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
  ];
}
