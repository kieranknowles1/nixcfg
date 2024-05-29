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
        lib_name=$(basename $file .nix)
        human_name="$lib_name"

        ${nixdoc} --category "$lib_name" --description "$human_name" --file "$file" >> $OUTPUT
      done
    '';

  in "${docs}/index.md";
}
