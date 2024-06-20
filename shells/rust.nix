{
  pkgs,
  flakeLib
}: flakeLib.shell.mkShellEx {
  packages = with pkgs; [
    cargo
    rustc
    gcc # Rust needs a linker
  ];
}
