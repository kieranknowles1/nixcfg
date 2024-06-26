{
  pkgs,
  flakeLib,
}: let
  packagePythonScript = flakeLib.package.packagePythonScript;

  factorioDecoderSrc = pkgs.fetchFromGitHub {
    owner = "kieranknowles1";
    repo = "factorio-blueprint-decoder";
    rev = "master";
    hash = "sha256-vY2As4HbxmfePptOfISPJEMMRRYbRyez3A/qSS5LGXo=";
  };
in {
  clean-skse-cosaves = packagePythonScript "clean-skse-cosaves" ./clean-skse-cosaves.py "1.0.1";

  combine-blueprints = packagePythonScript "combine-blueprints" ./combine-blueprints.py "1.0.0";

  export-blueprints = packagePythonScript "export-blueprints" ./export-blueprints.py "1.0.0";

  factorio-blueprint-decoder = packagePythonScript "factorio-blueprint-decoder" "${factorioDecoderSrc}/decode" "0.1.1";

  rebuild = import ./rebuild {inherit pkgs;};
}
