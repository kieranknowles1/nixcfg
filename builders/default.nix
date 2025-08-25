{
  pkgs,
  lib,
  inputs,
}: let
  callPackage = lib.customisation.callPackageWith (pkgs // inputs);
in {
  # TODO: Flake schemas once they're merged
  buildGodotApp = callPackage ./buildGodotApp.nix {};
  buildStaticSite = callPackage ./buildStaticSite {};
  buildScript = callPackage ./buildScript.nix {};
  fromHeif = callPackage ./fromHeif.nix {};
  mkFunctionDocs = callPackage ./mkFunctionDocs.nix {};
  mkOptionDocs = callPackage ./mkOptionDocs.nix {};
}
