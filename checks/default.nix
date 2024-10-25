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
          set -e
          bash ${script} ${builtins.concatStringsSep " " args}
          touch $out
        '';
    in {
      duplicate-input = mkCheck {
        nativeBuildInputs = with pkgs; [jq];
        script = ./duplicate-input.sh;
        name = "check-duplicate-input";
        args = ["${self}/flake.lock"];
      };

      markdown-links = mkCheck {
        nativeBuildInputs = with pkgs; [nodePackages.markdown-link-check];
        script = ./markdown-links.sh;
        name = "check-markdown-links";
        # Don't check links to external sites, as Nix builds are meant to be reproducible
        # and external sites can change their content.
        # Also ignore files in ./docs/generated, as they are assumed to be OK.
        args = [./markdown-link-config.json self];
      };
    };
  };
}
