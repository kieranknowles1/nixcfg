{
  pkgs,
  flake,
}:
flake.lib.shell.mkShellEx {
  name = "rust";

  # Packages to put on the PATH
  packages = with pkgs; [
    cargo
    rustc
    gcc # Rust needs a linker
    pkg-config # Needed for rust-analyzer
  ];

  # Libraries needed for building
  buildInputs = with pkgs; [
    openssl
  ];

  # Rust-analyzer requires the standard library's source code to give
  # completions.
  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
}
