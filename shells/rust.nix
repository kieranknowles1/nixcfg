{
  pkgs,
  flakeLib
}: flakeLib.shell.mkShellEx {
  packages = with pkgs; [
    cargo
    rustc
    gcc # Rust needs a linker
    pkg-config # Needed for rust-analyzer
  ];

  # Rust-analyzer requires the standard library's source code to give
  # completions.
  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
}
