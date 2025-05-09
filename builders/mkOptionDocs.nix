{
  lib,
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
module : The root module to generate documentation for. E.g., self.nixosModules.default

title : The title to include in the generated documentation

repoPath : The path to the repository containing the module
*/
{
  module,
  title,
  repoPath,
  prefix ? (toString self),
}: let
  eval = self.lib.docs.evalUnchecked module;
  optionsDoc = nixosOptionsDoc {
    inherit (eval) options;
    transformOptions = opt:
      opt
      // {
        declarations =
          map (decl: rec {
            name = lib.removePrefix "${prefix}/" decl;
            url = "${repoPath}/${name}";
          })
          opt.declarations;
      };
  };
in
  writeText "option-docs.md" ''
    # ${title}
    ${builtins.readFile optionsDoc.optionsCommonMark}
  ''
