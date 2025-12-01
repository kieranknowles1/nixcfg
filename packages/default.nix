{
  self,
  inputs,
  lib,
  ...
}: {
  perSystem = {
    system,
    pkgs,
    ...
  }: let
    callPackage = lib.customisation.callPackageWith (pkgs
      // inputs
      // self.builders.${system});
  in {
    packages = {
      activate-mutable = callPackage ./activate-mutable {};
      all-configurations = callPackage ./all-configurations.nix {};
      checkleak = callPackage ./checkleak {};
      combine-blueprints = callPackage ./combine-blueprints {};
      command-palette = callPackage ./command-palette {};
      export-blueprints = callPackage ./export-blueprints {};
      export-notes = callPackage ./export-notes {};
      extract = callPackage ./extract {};
      foodle = callPackage ./foodle/default.nix {};
      keyboardvis = callPackage ./keyboardvis {};
      nix-utils = callPackage ./nix-utils {};
      nvim = callPackage ./nvim {};
      openmw-luadata = callPackage ./openmw-luadata {};
      portfolio = callPackage ./portfolio {};
      rebuild = callPackage ./rebuild {};
      resaver = callPackage ./resaver {};
      scandoc = callPackage ./scandoc {};
      set-led-state = callPackage ./set-led-state {};
      skyrim-utils = callPackage ./skyrim-utils {};
      spriggit = callPackage ./spriggit.nix {};
      tlro = callPackage ./tlro {};
      todos = callPackage ./todos {};
    };
  };
}
