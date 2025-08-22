# Utility functions for working with attribute sets.
rec {
  /*
  Deeply merges a list of sets into a single set.
  If a key is present in multiple sets, the values are merged with the following rules:
  - Sets are merged using this function
  - Lists are concatenated
  - All other values are taken from the first set they appear in

  Note: It is assumed that repeated values are of the same type in all sets.

  # Example
  ```nix
  deepMergeSets [
    { a = 1; b = [2]; c = { d = 3; e = 4; }; };
    { a = 2; b = [3]; c = { d = 5; f = 6; }; };
  ] => {
    a = 1; # First value is taken
    b = [2 3]; # Lists are concatenated, in the order the sets are given
    c = {
      d = 3; # Sets are merged recursively, with the same rules
      e = 4; # Unique keys are are kept as-is
      f = 6;
    };
  };
  ```

  # Arguments
  **sets** (List\<AttrSet\>) : The sets to merge
  */
  deepMergeSets = sets:
    builtins.zipAttrsWith
    (_name: values: let
      first = builtins.elemAt values 0;
    in
      if builtins.isAttrs first
      then deepMergeSets values # Recurse into nested sets
      else if builtins.isList first
      then builtins.concatLists values # Concatenate lists
      else first) # We don't want to merge other types, so give the first value precedence
    
    sets;
}
