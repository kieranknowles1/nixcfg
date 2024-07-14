{pkgs}:
pkgs.rustPlatform.buildRustPackage {
  pname = "edit-config";
  version = "4.0.0";
  src = ./.;

  cargoHash = "sha256-PfU/jT3RWmmXluYAESHgW98bH8OwTjaOXP+foCH6hjE=";

  meta = {
    description = "A tool to edit configuration files";
    longDescription = ''
      Edit configuration that are provisioned by nix in their original location,
      so that you can see the changes live. After you are done editing,
      your changes are saved to the repository and Nix's files are restored.
    '';
  };
}
