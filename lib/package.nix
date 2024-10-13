{
  withSystem,
  lib,
  ...
}: {
  # TODO: Don't use withSystem, it makes building on ARM harder
  flake.lib.package = withSystem "x86_64-linux" ({pkgs, ...}: {
    /*
    Package a Python script as a standalone executable.

    A shebang for Python 3 is prepended automatically, although including it in
    the source is recommended to aid in debugging.

    Only works with simple scripts, that is, a single file with no dependencies
    outside of the standard library.

    # Arguments
    script :: String : The name of the output executable.

    src :: String : The path to the script to package or the script itself

    version :: String : The version of the script.

    meta :: AttrSet : Metadata for the package. See [Meta-attributes](https://ryantm.github.io/nixpkgs/stdenv/meta/) for more information.

    runtimeInputs :: List = null : A list of packages to include on the PATH when running the script.

    python :: Derivation : The Python interpreter and packages to use. Can be overridden with additional packages:
    ```nix
    python312.withPackages (python-pkgs: [
      python-pkgs.requests
    ]);
    ```
    */
    packagePythonScript = {
      name,
      src,
      version ? "1.0",
      meta ? {},
      runtimeInputs ? null,
      python ? pkgs.python312,
    }: let
      useWrapper = runtimeInputs != null;

      script = pkgs.stdenv.mkDerivation {
        pname =
          if useWrapper
          then "${name}-wrapped"
          else name;
        inherit version src runtimeInputs;

        dontUnpack = true; # This is a text file, unpacking is only applicable to archives
        installPhase = ''
          mkdir -p $out/bin

          shebang="#!${lib.getExe python}"

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
      wrapper = pkgs.writeShellScriptBin name ''
        export PATH="$PATH:${lib.strings.makeBinPath runtimeInputs}"
        exec ${script}/bin/${name} "$@"
      '';
    in
      if useWrapper
      then wrapper
      else script;

    /*
    Generate an XDG desktop entry file for a command.
    See https://wiki.archlinux.org/title/desktop_entries#Application_entry
    and https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html#recognized-keys
    for more information.

    # Arguments
    command :: Path : The command to run. Used for the `Exec` field.
    description :: String : A brief description of the command. Used for the `Comment` field.
    name :: String : The name of the desktop entry.
    version :: String : The version of the desktop entry. Defaults to "1.0".
    workingDirectory :: String : The working directory for the command. Used for the `Path` field.

    # Returns
    String : The contents of the desktop entry file.
    */
    mkDesktopEntry = {
      command,
      description,
      name,
      version ? "1.0",
      workingDirectory ? null,
    }: ''
      [Desktop Entry]
      Type=Application
      Version=${version}
      Name=${name}
      Comment=${description}
      Exec=${command}
      ${
        if (workingDirectory != null)
        then "Path=${workingDirectory}"
        else ""
      }
    '';
  });
}
