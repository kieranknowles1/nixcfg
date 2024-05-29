{ nixpkgs }: let
  # TODO: Don't repeat importing packages in every function.
  pkgs = import nixpkgs { system = "x86_64-linux"; };
in {
  /**
    Generate documentation for the functions in the given directory.

    # Example
    ```nix
    mkDocs ./lib
    => ./result/index.md
    ```

    # Arguments
    path
    : The directory containing the functions to document.
   */
  mkDocs = path: let
    nixdoc = "${pkgs.nixdoc}/bin/nixdoc";

    docs = pkgs.runCommand "mkDocs" {} ''
      mkdir -p $out
      OUTPUT="$out/index.md"

      for file in $(find "${path}" -type f -name '*.nix'); do
        # TODO: Skip any default.nix files.

        lib_name=$(basename $file .nix)
        # TODO: Capitalize the first letter of the name or have a way to specify the human name.
        human_name="$lib_name"

        # TODO: Add 2 more hashes to any headers to compensate for the 2 used by the nixdoc command.
        ${nixdoc} --category "$lib_name" --description "$human_name" --file "$file" >> $OUTPUT
      done
    '';

  in "${docs}/index.md";
}
