{
  pkgs,
  flakeLib,
}: let
  packagePythonScript = flakeLib.package.packagePythonScript;
in {
  /**
    Capitalize the first letter of a string
   */
  capitalize = packagePythonScript "capitalize" ''
    from sys import argv
    print(argv[1].capitalize())
  '' "1.0.0";

  /**
    Replace all occurrences of argv[2] in argv[1] with argv[3]
   */
  replace = packagePythonScript "replace" ''
    from sys import argv
    print(argv[1].replace(argv[2], argv[3]))
  '' "1.0.0";

  clean-skse-cosaves = packagePythonScript "clean-skse-cosaves" ./clean-skse-cosaves.py "1.0.1";
}
