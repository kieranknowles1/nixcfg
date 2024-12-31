{
  self,
  gnused,
  runCommand,
  nixosOptionsDoc,
}:
/*
Generate documentation for the given module's options. Does not include
options from its dependencies.
Generate documentation for the options in the given directory

# Example
```nix
mkOptionDocs ./modules/nixos
=> Markdown file
```

# Type
mkOptionDocs :: Path -> Path

# Arguments
importer : The file to import all modules containing options

header : The header to include in the generated documentation
*/
importer: header: let
  # File containing options documentation
  eval = self.lib.docs.evalModules importer;
  optionsDoc = nixosOptionsDoc {
    inherit (eval) options;
  };
  # Nix regexes only support complete matches, so we can't easily match the store path.
  # Instead, we'll remove it with sed.
  # Use pipe as a delimiter to avoid confusion with slashes
  # TODO: Can we make the link point to the repository?
in
  runCommand "option-docs.md" {
    buildInputs = [gnused];
  } ''
    echo "# ${header}" > $out
    cat ${optionsDoc.optionsCommonMark} | sed --regexp-extended 's|\/nix/store/[a-z0-9]{32}-source/||g' >> $out
  ''
