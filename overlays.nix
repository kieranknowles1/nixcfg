{
  self,
  inputs,
  ...
}: let
  /*
  Helper to create a namespace for a set of packages.

  # Arguments
  - `name`: The name to put packages under. Will be overlaid onto nixpkgs.
  - `packages`: The packages to put under the namespace. Should be a flake's outputs before system types.
  - `extra`: Anything extra to add to the namespace, such as a `lib` module.

  # Returns
  An overlay function that adds the namespace to nixpkgs.
  */
  mkNamespace = name: packages: extra: (_final: prev: let
    inherit (prev.stdenv.hostPlatform) system;
    namespacePkgs = packages.${system};
  in {
    "${name}" = namespacePkgs // extra;
  });
in {
  flake.overlays = {
    default = mkNamespace "flake" self.packages {
      inherit (self) lib;
    };

    nixpkgs-stable = mkNamespace "stable" inputs.nixpkgs-stable.legacyPackages {};
    nixpkgs-unstable = mkNamespace "unstable" inputs.nixpkgs.legacyPackages {};

    firefox-addons = mkNamespace "firefox-addons" inputs.firefox-addons.packages {};

    # Also add overlays needed by the flake
    # TODO: nixvim requires nixpkgs-unstable
    # nixvim = flake.inputs.nixvim.overlays.default;
    vscode-extensions = inputs.vscode-extensions.overlays.default;
  };
}
