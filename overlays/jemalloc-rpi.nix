_nixpkgs: lib:
# TODO: This entire overlay is only needed due to an upstream issue
# See https://github.com/nvmd/nixos-raspberrypi/issues/64
_final: prev:
let
  # Apply `override` if on ARM. Do nothing otherwise
  optionalOverride =
    override: pkg: if prev.system == "aarch64-linux" then pkg.overrideAttrs override else pkg;

  # Fix a package using https://crates.io/crates/tikv-jemalloc-sys
  fixupRs = optionalOverride (oldAttrs: {
    env = oldAttrs.env // {
      # log2(16384) as returned by
      JEMALLOC_SYS_WITH_LG_PAGE = "14";
    };
  });

  disableChecks = optionalOverride (_oldAttrs: {
    doCheck = false;

    pytestFlagsArray = [
      "-m"
      "'false'"
    ];
  });
in
{
  jemalloc = optionalOverride (old: {
    configureFlags = (lib.filter (flag: flag != "--with-lg-page=16") old.configureFlags) ++ [
      "--with-lg-page=14"
    ];
  }) prev.jemalloc;

  difftastic = fixupRs prev.difftastic;

  # Needed to make postgres use overlays. This still isn't enough, ew.
  # Update postgres16, as that's what immich requires

  postgresql16Packages = prev.postgresql16Packages // {
    pgvecto-rs = fixupRs prev.postgresql_16.pkgs.pgvecto-rs;
  };

  # Disable checks that are either
  # - slow
  # - flaky (some time out if we're under load)

  # This seems a bit flaky and is very slow
  valkey = disableChecks prev.valkey;
  # It's a hashmap, what could go wrong?
  redis = disableChecks prev.redis;
  # Let's trust upstream
  folly = disableChecks prev.folly;
  fizz = disableChecks prev.fizz;
  jellyfin-ffmpeg = disableChecks prev.jellyfin-ffmpeg;

  # That's a lot of trust to put on upstream :)
  python313Packages = prev.python313Packages // {
    moto = disableChecks prev.python313Packages.moto;
  };
}
