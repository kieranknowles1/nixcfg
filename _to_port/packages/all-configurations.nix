{
  stdenv,
  self,
  lib,
}:
stdenv.mkDerivation {
  name = "all-configurations";
  src = ./.;

  # Link all hosts to $out, this makes the derivation depend on each NixOS
  # configuration. Building this will run in parallel. The pi, being an ARM system,
  # is built remotely which coincidentally leaves everything in place for activation.
  buildPhase = let
    linkConfig = name: host: "ln -s ${host.config.system.build.toplevel} $out/${name}";
  in ''
    mkdir -p $out
    ${builtins.concatStringsSep "\n" (lib.mapAttrsToList linkConfig self.nixosConfigurations)}
  '';

  meta = {
    inherit (self.lib) license;

    description = "All NixOS configurations";
    longDescription = ''
      All of this flake's NixOS configurations in a single derivation.
    '';
  };
}
