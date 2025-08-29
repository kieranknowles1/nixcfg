{ self, ... }:
{
  imports = [
    ./tests
  ];

  perSystem =
    { pkgs, ... }:
    {
      checks =
        let
          # Make a check that will succeed if the script exits 0, and fail otherwise.
          # The path to the flake is passed as the first argument to the script.
          mkCheck =
            file: nativeBuildInputs: description:
            let
              name = builtins.replaceStrings [ ".sh" ] [ "" ] (baseNameOf file);
            in
            pkgs.runCommand name
              {
                inherit nativeBuildInputs;
                meta.description = description;
              }
              ''
                set -euo pipefail
                # $self is ok here as most checks apply to the entire flake
                bash ${file} ${self}
                touch $out
              '';
        in
        {
          bash-sanity = mkCheck ./bash-sanity.sh [ ] "Perform simple sanity checks on bash scripts";
          duplicate-input = mkCheck ./duplicate-input.sh [ pkgs.jq ] "Check for duplicate flake inputs";
          markdown-links = mkCheck ./markdown-links.sh [
            pkgs.lychee
          ] "Check for broken internal links in markdown files";
          symlinks = mkCheck ./symlinks.sh [ ] "Check for broken symlinks";
        };
    };
}
