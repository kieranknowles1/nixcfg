_nixpkgs: lib:
# TODO: This entire overlay is only needed due to an upstream issue
# See https://github.com/nvmd/nixos-raspberrypi/issues/64
_final: prev: let
  # Fix a package using https://crates.io/crates/tikv-jemalloc-sys
  fixupRs = pkg:
    if prev.system == "aarch64-linux"
    then
      pkg.overrideAttrs (_oldAttrs: {
        env = {
          # log2(16384) as returned by
          JEMALLOC_SYS_WITH_LG_PAGE = "14";
        };
      })
    else pkg;

  disableChecks = pkg:
    pkg.overrideAttrs (_oldAttrs: {
      doCheck = false;
    });
in {
  jemalloc = prev.jemalloc.overrideAttrs (old: {
    configureFlags =
      (lib.filter (flag: flag != "--with-lg-page=16") old.configureFlags)
      ++ [
        "--with-lg-page=14"
      ];
  });

  difftastic = fixupRs prev.difftastic;

  # This seems a bit flaky and is very slow
  valkey = disableChecks prev.valkey;
  # It's a hashmap, what could go wrong?
  redis = disableChecks prev.redis;
  # Let's trust upstream
  folly = disableChecks prev.folly;
  fizz = disableChecks prev.fizz;

  # Needed to make postgres use overlays. Still not enough, see `postgresql.nix`
  # for actually using these.

  postgresql16Packages =
    prev.postgresql16Packages
    // {
      pgvecto-rs = fixupRs prev.postgresql_16.pkgs.pgvecto-rs;
    };
}
