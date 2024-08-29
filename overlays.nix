flake: let
  /*
  Helper to create a namespace for a set of packages.

  # Arguments
  - `name`: The name to put packages under. Will be overlaid onto nixpkgs.
  - `packages`: The packages to put under the namespace. Should be a flake's outputs before system types.
  - `extra`: Anything extra to add to the namespace, such as a `lib` module.

  # Returns
  An overlay function that adds the namespace to nixpkgs.
  */
  mkNamespace = name: packages: extra: (final: prev: let
    system = prev.stdenv.hostPlatform.system;
    namespacePkgs = packages.${system};
  in {
    "${name}" = namespacePkgs // extra;
  });
in {
  default = mkNamespace "flake" flake.packages {
    lib = flake.lib;
  };

  nixpkgs-stable = mkNamespace "stable" flake.inputs.nixpkgs.legacyPackages {};
  nixpkgs-unstable = mkNamespace "unstable" flake.inputs.nixpkgs.legacyPackages {};

  firefox-addons = mkNamespace "firefox-addons" flake.inputs.firefox-addons.packages {};

  # Also add overlays needed by the flake
  # TODO: nixvim requires nixpkgs-unstable
  # nixvim = flake.inputs.nixvim.overlays.default;
  vscode-extensions = flake.inputs.vscode-extensions.overlays.default;
}