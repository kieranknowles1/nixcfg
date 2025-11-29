{
  cargo,
  rustc,
  mkShell,
  openssl,
  pkg-config,
  rust,
  flake,
}:
flake.lib.shell.mkShellEx mkShell {
  name = "rust";

  # Packages to put on the PATH
  nativeBuildInputs = [
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
}
