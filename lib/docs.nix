{
  pkgs,
  flake,
}: {
  /**
    Generate documentation for the functions in the given directory.

    # Example
    ```nix
    mkFunctionDocs ./lib
    => ./result/index.md
    ```

    # Type
    mkFunctionDocs :: Path -> Path

    # Arguments
    path :: Path
    : The directory containing the functions to document.
   */
  mkFunctionDocs = path: let
    nixdoc = "${pkgs.nixdoc}/bin/nixdoc";

    docs = pkgs.runCommand "mkFunctionDocs" {} ''
      mkdir -p $out
      OUTPUT="$out/index.md"

      for file in $(find "${path}" -type f -name '*.nix'); do
        # Skip default.nix files, including those in subdirectories via wildcards.
        if [[ $file == *default.nix ]]; then
          continue
        fi

        lib_name=$(basename "$file" .nix | tr '/' '.')
        # https://stackoverflow.com/questions/1538676/uppercasing-first-letter-of-words-using-sed
        # s| uses | as a delimiter, to avoid confusion with slashes
        # \<. matches the first character of each word when combined with |g for global matching
        # \U& converts the matched character to uppercase
        human_name=$(echo "$lib_name" | sed 's|\<.|\U&|g')

        # TODO: Find a way to make links between functions.
        ${nixdoc} --category "$lib_name" --description "$human_name" --file "$file" >> $OUTPUT
      done
    '';

  in "${docs}/index.md";


  /**
    Generate documentation for the options in the given directory

    # Example
    ```nix
    mkOptionDocs ./modules/nixos
    => Markdown text
    ```

    # Type
    mkOptionDocs :: Path -> Path

    # Arguments
    importer
    : The file to import all modules containing options
   */
  mkOptionDocs = importer: let
    modulesEval = pkgs.lib.evalModules {
      modules = [
        importer
        # Don't eval flake inputs, we don't want to generate documentation for them.
        # The checks this disables are already being done during build time.

        # This works because evalModules is not passed anything from the flake inputs, such as nixpkgs.
        # Disabling checks supresses the missing input error (which is expected and any unexpected error will have already been caught).
        { config._module.check = false; }
      ];
    };

    optionsDoc = pkgs.nixosOptionsDoc {
      options = modulesEval.options;
    };
  in optionsDoc.optionsCommonMark;
}
