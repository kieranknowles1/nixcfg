{
  nixpkgs,
  flake,
}: let
  # TODO: Don't repeat importing packages in every function.
  pkgs = import nixpkgs { system = "x86_64-linux"; };
  flakePkgs = flake.packages.x86_64-linux;
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
    capitalise = "${flakePkgs.capitalize}/bin/capitalize";
    replace = "${flakePkgs.replace}/bin/replace";

    docs = pkgs.runCommand "mkFunctionDocs" {} ''
      mkdir -p $out
      OUTPUT="$out/index.md"

      for file in $(find "${path}" -type f -name '*.nix'); do
        # Skip default.nix files, including those in subdirectories via wildcards.
        if [[ $file == *default.nix ]]; then
          continue
        fi

        lib_name=$(${replace} $(basename $file .nix) '/' '.')
        human_name=$(${capitalise} $lib_name)

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

        # This works because evalModules is not passed anything from the flake inputs, such as nixpkgs.
        # Disabling checks supresses the missing input error (which is expected and any unexpected error will have already been caught).
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
