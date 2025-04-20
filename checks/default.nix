{self, ...}: {
  perSystem = {pkgs, ...}: {
    checks = let
      # Make a check that will succeed if the script exits 0, and fail otherwise.
      # The path to the flake is passed as the first argument to the script.
      mkCheck = name: nativeBuildInputs:
        pkgs.runCommand "check-${name}" {inherit nativeBuildInputs;} ''
          set -euo pipefail
          bash ${./${name}.sh} ${self}
          touch $out
        '';
    in {
      bash-sanity = mkCheck "bash-sanity" [];
      duplicate-input = mkCheck "duplicate-input" [pkgs.jq];
      markdown-links = mkCheck "markdown-links" [pkgs.lychee];
      symlinks = mkCheck "symlinks" [];
    };
  };
}
