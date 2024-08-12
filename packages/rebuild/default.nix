{pkgs}:
pkgs.rustPlatform.buildRustPackage {
  pname = "rebuild";
  version = "2.1.0";
  src = ./.;

  cargoHash = "sha256-xvv5LJcZ5FF+LIuEktVvQQwqVXBfa/yBH2q66WLn7OM=";

  meta = {
    description = "Wrapper for common Nix build workflows";
    longDescription = ''
      Rebuild the system and commit the changes to the repository.

      The commit message contains metadata such as a generation number, the
      builder's hostname, and a diff of packages.
    '';

    mainProgram = "rebuild";
  };
}
