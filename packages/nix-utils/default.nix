{
  nushell,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "nix-utils";
  version = "1.1.0";

  src = ./.;
  buildInputs = [
    nushell
  ];

  # Iterate over all files in $src apart from default.nix, copy them to
  # $out/bin, remove extensions, and patch the shebang to point to the nix store
  # While /usr/bin/env works as long as the executable is on the path, using absolute
  # paths makes it clear what a script depends on and makes using them in a builder easier
  # (see how flake-tree is called in [[modules/home/docs.nix]])
  buildPhase = ''
    mkdir -p $out/bin

    for file in $(ls $src); do
      if [ "$file" != "default.nix" ]; then
        noextension="''${file%.*}"
        infile=$src/$file
        outfile=$out/bin/$noextension
        if [[ ! -x "$infile" ]]; then
          echo "Error: $file is not executable" >&2
          exit 1
        fi

        # NOTE: If the shebang's exe is not available to the build environment, this will silently fail
        exe="$(head -n 1 $infile | sed 's|#!/usr/bin/env ||')"
        echo "#!/$(command -v $exe)" >> $outfile
        tail -n +2 $infile >> $outfile
        chmod +x $outfile
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
