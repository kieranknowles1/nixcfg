{
  stdenv,
  godot_4,
}:
/*
Build a Godot application from the given source directory.

Based on https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/by-name/pi/pixelorama/package.nix

# Arguments
src :: String : Root directory of the Godot project.
name :: String : Name of the application.
version :: String : Version of the application.
meta :: AttrSet : [Meta-attributes](https://ryantm.github.io/nixpkgs/stdenv/meta/) for the application.
*/
{
  src,
  name,
  version ? null,
  meta ? {},
}: let
  inherit (stdenv.hostPlatform) system;
  inherit (godot_4) export-template;
  preset =
    {
      "x86_64-linux" = "Linux";
    }.${
      system
    };
  templateExe = let
    name =
      {
        "x86_64-linux" = "linux_release.x86_64";
      }.${
        system
      };
    version = builtins.replaceStrings ["-stable"] [".stable"] godot_4.version;
  in "${export-template}/share/godot/export_templates/${version}/${name}";
in
  stdenv.mkDerivation {
    inherit src version meta;
    pname = name;

    buildInputs = [godot_4];

    buildPhase = ''
      # Godot expects export templates in a specific directory
      export HOME=$(mktemp -d)
      mkdir -p $HOME/.local/share/godot
      ln -s "${export-template}/share/godot/export_templates" $HOME/.local/share/godot/

      # Exporting uses the final path component as an app name, preserve the original.
      mkdir -p build
      godot4 --headless --export-release "${preset}" "./build/${name}"

      # We only care about the .pck file, the executable can be reused between
      # multiple apps running the same engine version.
      mkdir -p $out
      cp "./build/${name}.pck" $out
      ln -s "${templateExe}" $out/${name}
    '';
  }
