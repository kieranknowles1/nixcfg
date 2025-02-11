{stdenv}:
stdenv.mkDerivation {
  pname = "nix-utils";
  version = "1.1.0";

  src = ./.;

  # Nix automatically patches the shebangs to point to the
  # store.
  # Iterate over all files, copy them to $out/bin, and remove
  # the .sh extension, excluding the default.nix file.
  buildPhase = ''
    mkdir -p $out/bin

    for file in $(ls $src); do
      if [ "$file" != "default.nix" ]; then
        if [[ ! -x "$src/$file" ]]; then
          echo "Error: $file is not executable" >&2
          exit 1
        fi

        cp "$src/$file" "$out/bin/$(basename $file .sh)"
      fi
    done
  '';

  meta = {
    description = "Miscellaneous shell utilities";
    longDescription = ''
      Single-word commands for common tasks, including:
      - `confbuild`: Build a derivation specified as a Nix option
      - `confeval`: Evaluate a Nix option's value, as JSON
      - `check`: Build a check for the current flake
      - `gr`: Utilities for working with Git remotes
      # FIXME: Remove .nu extension when building
      - `flake-tree`: Print the dependency tree of a flake, either as a Nushell table or Graphviz dot file
      - `run`: Run a Nix package from the current repository
      - `venv`: Activate a Python virtual environment, shell-agnostic version

      All commands take the first argument as the target name, defaulting
      to `default` if not provided. When relevant, remaining arguments are
      passed to the target.

      These are implemented as bash scripts instead of shell aliases
      as they need special handling of the first argument.
    '';
  };
}
