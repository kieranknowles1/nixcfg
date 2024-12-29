{
  stdenv,
  lib,
  writeShellScriptBin,
}:
/*
Package a script as a standalone executable, similar to `pkgs.writeShellScriptBin`.

Only works with simple scripts, that is, a single file with no dependencies
outside of the standard library.

# Arguments
runtime :: String : The runtime the script requires, such as Python or Nushell.

script :: String : The name of the output executable.

src :: String : The path to the script to package or the script itself

version :: String : The version of the script.

meta :: AttrSet : Metadata for the package. See [Meta-attributes](https://ryantm.github.io/nixpkgs/stdenv/meta/) for more information.

runtimeInputs :: List = null : A list of packages to include on the PATH when running the script.
```nix
python312.withPackages (python-pkgs: [
  python-pkgs.requests
]);
```
*/
{
  runtime,
  name,
  src,
  version ? "1.0",
  meta ? {},
  runtimeInputs ? null,
}: let
  useWrapper = runtimeInputs != null;

  script = stdenv.mkDerivation {
    pname =
      if useWrapper
      then "${name}-wrapped"
      else name;
    inherit version src runtimeInputs;

    dontUnpack = true; # This is a text file, unpacking is only applicable to archives
    installPhase = ''
      mkdir -p $out/bin

      shebang="#!${lib.getExe runtime}"

      echo "$shebang" > $out/bin/${name}
      cat $src >> $out/bin/${name}
      chmod +x $out/bin/${name}
    '';

    meta =
      meta
      // {
        # lib.getExe expects this to be set, and raises a warning if it isn't
        mainProgram = name;
      };
  };

  # If we need to include additional packages on the PATH, generate a wrapper
  # that extends PATH with the runtime inputs.
  wrapper = writeShellScriptBin name ''
    export PATH="$PATH:${lib.strings.makeBinPath runtimeInputs}"
    exec ${script}/bin/${name} "$@"
  '';
in
  if useWrapper
  then wrapper
  else script
