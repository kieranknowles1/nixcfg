{pkgs}:
pkgs.rustPlatform.buildRustPackage {
  pname = "edit-config";
  version = "4.1.0";
  src = ./.;

  cargoHash = "sha256-USN7E0ZmwaD7pVbLdxAuILIQNHBN3Tdintlvc1JqGSk=";

  meta = {
    description = "A tool to edit configuration files";
    longDescription = ''
      Edit configuration that are provisioned by nix in their original location,
      so that you can see the changes live. After you are done editing,
      your changes are saved to the repository and Nix's files are restored.
    '';
  };
}
