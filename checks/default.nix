{self, ...}: {
  perSystem = {pkgs, ...}: {
    checks = {
      duplicate-input = pkgs.runCommand "check-duplicate-input" {
        nativeBuildInputs = with pkgs; [jq];
        LOCK_FILE = "${self}/flake.lock";
      } (builtins.readFile ./duplicate-input.sh);

      markdown-links =
        pkgs.runCommand "check-markdown-links" {
          nativeBuildInputs = with pkgs; [nodePackages.markdown-link-check];
        } ''
          # Don't check links to external sites, as Nix builds are meant to be reproducible
          # and external sites can change their content.
          # Also ignore files in ./docs/generated, as they are assumed to be OK.
          bash ${./markdown-links.sh} ${./markdown-link-config.json} ${self}
          touch $out
        '';
    };
  };
}
