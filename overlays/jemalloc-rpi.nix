# TODO: This entire overlay is only needed due to an upstream issue
# See https://github.com/nvmd/nixos-raspberrypi/issues/64
_final: prev: let
  # Fix a package using https://crates.io/crates/tikv-jemalloc-sys
  fixup = pkg:
    if prev.system == "aarch64-linux"
    then
      pkg.overrideAttrs (_oldAttrs: {
        env = {
          JEMALLOC_SYS_WITH_LG_PAGE = "14";
        };
      })
    else pkg;
in {
  difftastic = fixup prev.difftastic;
}
