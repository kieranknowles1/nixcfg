{
  pkgs,
  lib,
  clan-core,
}: let
  evalModules = importer:
    pkgs.lib.evalModules {
      modules = [
        importer
        # Don't eval flake inputs, we don't want to generate documentation for them.
        # The checks this disables are already being done during build time.

        # This works because evalModules is not passed anything from the flake inputs, such as nixpkgs.
        # Disabling checks supresses the missing input error (which is expected and any unexpected error will have already been caught).
        {config._module.check = false;}
      ];
    };

  jsonLib = clan-core.lib.jsonschema {
    # Options can be overridden here.
  };
in {
  /*
  *
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

  /*
  *
  Generate documentation for the options in the given directory

  # Example
  ```nix
  mkOptionDocs ./modules/nixos
  => Markdown file
  ```

  # Type
  mkOptionDocs :: Path -> Path

  # Arguments
  importer
  : The file to import all modules containing options
  */
  mkOptionDocs = importer: let
    modulesEval = evalModules importer;

    optionsDoc = pkgs.nixosOptionsDoc {
      options = modulesEval.options;
    };
  in
    optionsDoc.optionsCommonMark;

  /*
  *
  Generate a JSON schema for options in the given directory

  # Example
  ```nix
  mkJsonSchema ./modules/nixos (opts: opts.foo)
  => JSON file

  # Toml is preferred for configuration files as it supports comments
  # and has a more nix-like syntax.
  config.foo = builtins.fromTOML (builtins.readFile ./config.toml)

  ```

  # Arguments
  importer :: Path : The file to import all modules containing options
  filter :: Func(AttrSet -> AttrSet) : A function to filter the options

  NOTE: If the filter function selects a subset of the options (e.g, opts.foo), the schema will only contain the
  selected options and they will have to be manually merged at the appropriate place.

  # Returns
  Path : The path to the generated JSON file


  */
  mkJsonSchema = importer: filter: let
    modulesEval = evalModules importer;
    filtered = filter modulesEval.options;
    # We can override a different set of options here.
    schemaNix = jsonLib.parseOptions filtered {};

    # Convert the Nix object to JSON to be consistent with the other docs-related functions.
    schemaJson = builtins.toJSON schemaNix;
  in
    pkgs.writeText "schema.json" schemaJson;

  /*
  *
  Generate documentation for the packages in the given set.
  Note that all packages must have a `meta` attribute. This function will error if any package is missing it.

  # Example
  ```nix
  mkPackageDocs pkgs.flake
  => Markdown file
  ```
  */
  mkPackageDocs = packages: let
    # pkgs may contain other attributes, such as `nixpkgs.lib`, so we need to filter them out.
    values = builtins.filter lib.attrsets.isDerivation (builtins.attrValues packages);

    # Nix combines pname with version to create the package name if pname is present.
    getName = package: package.pname or package.name;

    createTocEntry = package: let
      name = getName package;
    in ''
      - [${name}](#${pkgs.lib.strings.toLower name}) - ${package.meta.description or ""}
    '';

    createEntry = package: let
      name = getName package;
      version = package.version or "unknown";
      shortDescription = package.meta.description or "";

      # Add 2 levels of headers to any in the long description.
      # We reserve heading 1 for the file header, and heading 2 for the package name,
      # so descriptions need to start at heading 3.
      longDescription = let
        original = package.meta.longDescription or "";
      in
        builtins.replaceStrings ["\n#"] ["\n###"] original;

      noDescription = shortDescription == "" && longDescription == "";
    in ''
      ## ${name}
      version: ${version}

      ${
        if package.meta ? homepage
        then "Homepage: " + package.meta.homepage
        else ""
      }
      ${
        if package.meta ? license
        then "License: " + package.meta.license.fullName
        else ""
      }

      ${shortDescription}

      ${longDescription}
      ${
        if noDescription
        then "No description provided."
        else ""
      }
    '';
  in
    pkgs.writeText "packages.md" ''
      # Packages

      ${builtins.concatStringsSep "" (map createTocEntry values)}

      ${builtins.concatStringsSep "\n" (map createEntry values)}
    '';
}
