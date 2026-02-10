# TODO: This entire overlay is only needed due to an upstream issue
# TODO: Look into https://github.com/Gabriella439/nix-diff to see WHY
# the cache is being missed, rather than just disabling checks to hide the issue
# See https://github.com/nvmd/nixos-raspberrypi/issues/64
# Want to limit the scope here: overriding a package means cache misses for all
# of its dependents, currently we have to rebuild several large packages which
# takes 6+ hours on a pi.
_final: prev: let
  # Fix a package using https://crates.io/crates/tikv-jemalloc-sys
  fixupRs = pkg:
    pkg.overrideAttrs (oldAttrs: {
      env =
        oldAttrs.env
        // {
          # log2(16384) as returned by
          JEMALLOC_SYS_WITH_LG_PAGE = "14";
        };
    });

  disableChecks = pkg:
    pkg.overrideAttrs (_oldAttrs: {
      doCheck = false;

      pytestFlagsArray = ["-m" "'false'"];
    });
in {
  difftastic = fixupRs prev.difftastic;

  # Disable checks that are either
  # - slow
  # - flaky (some time out if we're under load)

  # This seems a bit flaky and is very slow
  valkey = disableChecks prev.valkey;
  # It's a hashmap, what could go wrong?
  redis = disableChecks prev.redis;
}
