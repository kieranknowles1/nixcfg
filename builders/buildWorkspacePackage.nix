{rustPlatform}:
/*
Build a package using Cargo.lock from the repository's root workspace.
*/
{
  pname,
  src,
  meta,
  patchPhase ? "",
}:
rustPlatform.buildRustPackage {
  inherit pname src;
  version = let
    toml = builtins.fromTOML (builtins.readFile "${src}/Cargo.toml");
  in
    toml.package.version;

  meta =
    meta
    // {
      mainProgram = pname;
    };

  cargoLock.lockFile = ../Cargo.lock;
  patchPhase = ''
    ln -s ${../Cargo.lock} .
    ${patchPhase}
  '';
}
