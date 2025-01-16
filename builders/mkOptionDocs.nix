{
  self,
  nixosOptionsDoc,
  writeText,
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
modules : The root module to generate documentation for. E.g., self.nixosModules.default

header : The header to include in the generated documentation
*/
module: title: let
  eval = self.lib.docs.evalUnchecked module;
  optionsDoc = nixosOptionsDoc {
    inherit (eval) options;
  };
in
  writeText "option-docs.md" ''
    # ${title}
    ${builtins.readFile optionsDoc.optionsCommonMark}
  ''
