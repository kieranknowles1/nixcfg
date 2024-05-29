{ nixpkgs }: let
  # TODO: Don't repeat importing packages in every function.
  pkgs = import nixpkgs { system = "x86_64-linux"; };
in {
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
        # TODO: Skip any default.nix files.

        lib_name=$(basename $file .nix)
        # TODO: Capitalize the first letter of the name or have a way to specify the human name.
        human_name="$lib_name"

        # TODO: Add 2 more hashes to any headers to compensate for the 2 used by the nixdoc command.
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
    modulesEval = nixpkgs.lib.evalModules {
      modules = [
        importer
        # Don't eval flake inputs, we don't want to generate documentation for them.
        # The checks this disables are already being done during build time.
        { config._module.check = false; }
      ];
    };

    optionsDoc = pkgs.nixosOptionsDoc {
      options = modulesEval.options;
    };
    # TODO: Maybe use something more readable than the default markdown. Only got a few options to document so it's not a big deal.
    # Could possibly use mkdocs or something similar.
  in optionsDoc.optionsCommonMark;
}
