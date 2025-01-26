{
  self,
  lib,
  ...
}: {
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

      markdown-links = let
        patch = pkgs.fetchurl {
          # Appending ".patch" to a PR URL will give you a patch file. Once the PR is merged,
          # The patch should fail to apply, and you can remove it.
          url = "https://github.com/tcort/markdown-link-check/pull/372.patch";
          sha256 = "sha256-Yx/NWUkYFR4Dein4UQs5NLqFp7Ys3mAnShjouwWorE0=";
        };

        link-check = pkgs.nodePackages.markdown-link-check.overrideAttrs (old: {
          patches = (old.patches or []) ++ [patch];
        });
      in
        # https://github.com/tcort/markdown-link-check/pull/372
        # When this assertion fails, see if the above PR has been merged, then either remove the patch or update the version.
        assert lib.asserts.assertMsg (pkgs.markdown-link-check.version == "3.13.6") "Check if markdown-link-check patch is still needed";
          mkCheck {
            nativeBuildInputs = [link-check];
            script = ./markdown-links.sh;
            name = "check-markdown-links";
            # Don't check links to external sites to keep the check as a pure function.
            # Also ignore files in ./docs/generated, as they are assumed to be OK.
            # TODO: Could we link the generated files into ./docs/generated, so that they are checked? Which host should they come from?
            args = [./markdown-link-config.json self];
          };

      bash-sanity = mkCheck {
        script = ./bash-sanity.sh;
        name = "check-bash-sanity";
        args = [self];
      };
    };
  };
}
