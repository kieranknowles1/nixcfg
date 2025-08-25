{
  self,
  inputs,
  lib,
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

  optionalOverlay = input: name:
    if builtins.hasAttr "overlays" input && builtins.hasAttr name input.overlays
    then input.overlays.${name}
    else (_: _: {});
in {
  default = mkNamespace "flake" self.packages {
    inherit (self) lib;
  };

  firefox-addons = mkNamespace "firefox-addons" inputs.firefox-addons.packages {};

  # Also add overlays consumed by the flake, makes activating everything easier
  vscode-extensions = optionalOverlay inputs.vscode-extensions "default";
  nix-topology = optionalOverlay inputs.nix-topology "default";

  overrides = import ./overrides.nix {inherit inputs;};
  jemalloc-rpi = import ./jemalloc-rpi.nix inputs.nixpkgs lib;
}
