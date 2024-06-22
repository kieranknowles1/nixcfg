{
  pkgs
}: {
  /**
    Package a Python script as a standalone executable.

    A shebang for Python 3 is prepended automatically, although including it in
    the source is recommended to aid in debugging.

    Only works with simple scripts, that is, a single file with no dependencies
    outside of the standard library.

    # Arguments
    script :: String : The name of the output executable.

    src :: String : The path to the script to package or the script itself

    version :: String : The version of the script.
   */
  packagePythonScript = name: src: version: pkgs.stdenv.mkDerivation rec {
    pname = name;
    inherit version src;

    dontUnpack = true; # This is a text file, unpacking is only applicable to archives
    installPhase = ''
      mkdir -p $out/bin

      shebang="#!${pkgs.python3}/bin/python3"

      echo "$shebang" > $out/bin/${pname}
      cat $src >> $out/bin/${pname}
      chmod +x $out/bin/${pname}
    '';
  };

  /**
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
    ${if (workingDirectory != null) then "Path=${workingDirectory}" else ""}
  '';
}
