{ }:
{
  /**
    Conditionally include packages in the build, if a subfeature is enabled.

    # Example
    ```nix
    environment.systemPackages = with pkgs; [
      git
    ] ++ (optionalPackages config.development.node.enable [
      nodejs
    ]);
    ```

    # Type
    optionalPackages :: Bool -> List -> List

    # Arguments
    condition :: Bool
    : The condition in which to include the packages.

    packages :: List
    : The packages to include if the condition is true.
    ])
   */
  optionalPackages = condition: packages: if condition then packages else [];
}
