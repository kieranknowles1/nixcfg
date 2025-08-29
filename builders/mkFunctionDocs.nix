{
  runCommand,
  nixdoc,
  jq,
}:
/*
  Generate documentation for the functions in the given directory.
  Directory must contain a `meta.json` in the following format:
  ```json
  entry[] where
  entry = {
    file: path,
    category: string, // Functions exposed under `lib.<category>`
    title: string,
  }
  ```

  # Example
  ```nix
  mkFunctionDocs ./lib
  => markdown file
  ```

  # Type
  mkFunctionDocs :: Path -> Path

  # Arguments
  path :: Path
  : The directory containing the functions to document.
*/
path:
runCommand "function-docs.md"
  {
    buildInputs = [
      jq
      nixdoc
    ];
  }
  ''
    cd "${path}";
    echo "# Function Documentation" > "$out"
    # 6 args: 3 pairs of flag + value
    # First sed:
    # Shift everything down a heading level. Nixdoc starts at <h1>, but we want <h2>
    # to stick with the one-h1 rule.
    #
    # Second sed:
    # Shift function descriptions, defined as not having a named anchor ({#id}),
    # down two more levels so they start at <h4> when including the global adjustments.
    # This gives the following structure:
    # - <h1> - Page title
    # - <h2> - Category
    # - <h3> - Function
    # - <h4+> - Description
    jq -r '.[] | "--file", @sh "\(.file)", "--category", @sh "\(.category)", "--description", @sh "\(.title)"' \
      "${path}/meta.json" | xargs -n 6 nixdoc | sed 's|^#|##|' |
      sed --regexp-extended 's|^#([^{}]+)$|###\1|' >> "$out"
  ''
