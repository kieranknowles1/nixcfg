# Library functions for generating documentation.
# Note that these functions return strings, and need to be written to files before inclusion in docs-generate.
{lib}: {
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

  /*
  Generate documentation for the packages in the given set.
  Note that all packages must have a `meta` attribute. This function will error if any package is missing it.

  # Example
  ```nix
  mkPackageDocs pkgs.flake
  => Markdown file
  ```

  # Arguments
  **packages** (AttrSet\<Package\>) : The packages to generate documentation for.
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
}
