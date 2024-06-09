{
  pkgs,
  flakeLib,
}: let
  packagePythonScript = flakeLib.package.packagePythonScript;
in {
  clean-skse-cosaves = packagePythonScript "clean-skse-cosaves" ./clean-skse-cosaves.py "1.0.1";

  edit-config = packagePythonScript "edit-config" ./edit-config.py "1.0.1";
}
