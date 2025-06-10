# Library functions for generating documentation.
# Note that these functions return strings, and need to be written to files before inclusion in docs-generate.
{
  lib,
  inputs,
  ...
}: let
  jsonLib = inputs.clan-core.lib.jsonschema {
    # Options can be overridden here.
  };
in {
  flake.lib.docs = rec {
    # Evaluate a single module, ignoring any errors caused by missing inputs.
    evalUnchecked = module:
      lib.evalModules {
        modules = [
          module
          # We aren't evaling flake inputs, as we don't want to generate documentation for them.
          # Ignore any errors caused by this, as they will be caught during the build.
          {config._module.check = false;}
        ];
      };

    # FIXME: This hasn't been working since the switch to flake-parts
    # /*
    # Generate documentation for the functions in the given directory.

    # # Example
    # ```nix
    # mkFunctionDocs ./lib
    # => ./result/index.md
    # ```

    # # Type
    # mkFunctionDocs :: Path -> Path

    # # Arguments
    # path :: Path
    # : The directory containing the functions to document.
    # */
    # mkFunctionDocs = path:
    #   pkgs.runCommand "function-docs.md" {} ''
    #     for file in $(find "${path}" -type f -name '*.nix'); do
    #       # Skip default.nix files, including those in subdirectories via wildcards.
    #       if [[ $file == *default.nix ]]; then
    #         continue
    #       fi

    #       lib_name=$(basename "$file" .nix | tr '/' '.')
    #       # https://stackoverflow.com/questions/1538676/uppercasing-first-letter-of-words-using-sed
    #       # s| uses | as a delimiter, to avoid confusion with slashes
    #       # \<. matches the first character of each word when combined with |g for global matching
    #       # \U& converts the matched character to uppercase
    #       human_name=$(echo "$lib_name" | sed 's|\<.|\U&|g')

    #       # TODO: Find a way to make links between functions.
    #       # TODO: Add extra hashes to make headers match the file
    #       ${lib.getExe pkgs.nixdoc} --category "$lib_name" --description "$human_name" --file "$file" >> $out
    #     done
    #   '';

    /*
    Generate a JSON schema for options in the given directory

    # Example
    ```nix
    mkJsonSchema ./modules/nixos (opts: opts.foo)
    => JSON file

    # TOML is preferred for configuration files as it supports comments
    # and has a more nix-like syntax, but JSON and YAML could also be used.
    config.foo = lib.host.readTomlFile ./config.toml

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
      modulesEval = evalUnchecked importer;
      filtered = filter modulesEval.options;
      # We can override a different set of options here.
      schemaNix = jsonLib.parseOptions filtered {};

      # Allow the `$schema` key to be used, as additionalProperties is false.
      schemaWithExtra =
        schemaNix
        // {
          properties =
            schemaNix.properties
            // {
              "$schema" = {type = "string";};
            };
        };
    in
      builtins.toJSON schemaWithExtra;

    /*
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
        - [${name}](#${lib.strings.toLower name}) - ${package.meta.description or ""}
      '';

      createEntry = package: let
        name = getName package;

        # h1 is for the page title, h2 is for the package name, so start at h3
        # in the description.
        incrementHeaders = builtins.replaceStrings ["\n#"] ["\n###"];
        getMetaOr = default: field: transform:
          if builtins.hasAttr field package.meta
          then transform package.meta.${field}
          else default;
        getMeta = getMetaOr "";
      in ''
        ## ${name}
        Version: ${package.version or "unknown"}

        ${getMeta "homepage" (x: "Homepage: [${x}](${x})")}

        ${getMetaOr "No License specified" "license" (x: "License: ${x.fullName}")}

        ${getMeta "description" (x: "*${x}*")}

        ${getMeta "longDescription" incrementHeaders}
      '';
    in ''
      # Packages

      ${builtins.concatStringsSep "" (map createTocEntry values)}

      ${builtins.concatStringsSep "\n" (map createEntry values)}
    '';
  };
}
