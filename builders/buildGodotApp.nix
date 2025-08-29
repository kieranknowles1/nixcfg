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
  meta ? { },
}:
let
  inherit (stdenv.hostPlatform) system;
  inherit (godot_4) export-template;
  preset =
    {
      "x86_64-linux" = "Linux";
    }
    .${system};
  templateExe =
    let
      name =
        {
          "x86_64-linux" = "linux_release.x86_64";
        }
        .${system};
      version = builtins.replaceStrings [ "-stable" ] [ ".stable" ] godot_4.version;
    in
    "${export-template}/share/godot/export_templates/${version}/${name}";
in
stdenv.mkDerivation {
  inherit src version;
  pname = name;

  meta = meta // {
    mainProgram = name;
  };

  buildInputs = [ godot_4 ];

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
    mkdir -p $out/bin $out/share/${name}
    PAKFILE="$out/share/${name}/${name}.pck"
    cp "./build/${name}.pck" "$PAKFILE"

    # Godot expects the executable to be paired with a .pck file, following
    # symlinks. Manually override this to use the correct path while still
    # reusing the executable.
    cat <<EOF > $out/bin/${name}
    #!/bin/sh
    exec "${templateExe}" --main-pack "$PAKFILE" "\$@"
    EOF
    chmod +x $out/bin/${name}
  '';
}
