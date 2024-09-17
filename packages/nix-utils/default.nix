{stdenv}:
stdenv.mkDerivation {
  pname = "nix-utils";
  version = "1.0.0";

  src = ./.;

  # Everything in this directory apart from default.nix is
  # a bash script. Simply copy them to the bin directory.
  # Nix automatically patches the shebangs to point to the
  # store.
  buildPhase = ''
    mkdir -p $out/bin

    cp -r $src/. $out/bin/
    rm $out/bin/default.nix
  '';

  meta = {
    description = "Utilities for working with Nix";
    longDescription = ''
      Single-word commands for common Nix tasks, including:
      - `dev`: Dev shell from the current repository
      - `devr`: Dev shell from the nixcfg repository
      - `run`: Run a Nix package from the current repository

      All commands take the first argument as the target name, defaulting
      to `default` if not provided. When relevant, remaining arguments are
      passed to the target.

      These are implemented as bash scripts instead of shell aliases
      as they need special handling of the first argument.
    '';
  };
}
