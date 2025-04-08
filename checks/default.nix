{self, ...}: {
  perSystem = {pkgs, ...}: {
    checks = let
      # Make a check that will succeed if the script exits 0, and fail otherwise.
      mkCheck = {
        nativeBuildInputs ? [],
        script,
        name,
        args ? [],
      }:
        pkgs.runCommand name {inherit nativeBuildInputs;} ''
          set -euo pipefail
          bash ${script} ${builtins.concatStringsSep " " args}
          touch $out
        '';
    in {
      bash-sanity = mkCheck {
        script = ./bash-sanity.sh;
        name = "check-bash-sanity";
        args = [self];
      };

      duplicate-input = mkCheck {
        nativeBuildInputs = with pkgs; [jq];
        script = ./duplicate-input.sh;
        name = "check-duplicate-input";
        args = ["${self}/flake.lock"];
      };

      markdown-links = mkCheck {
        nativeBuildInputs = with pkgs; [lychee];
        script = ./markdown-links.sh;
        name = "check-markdown-links";
        args = [self];
      };
    };
  };
}
