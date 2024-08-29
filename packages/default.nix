{
  pkgs,
  flake,
  inputs,
}: let
  packagePythonScript = flake.lib.package.packagePythonScript;
  callPackage = pkgs.callPackage;
  system = pkgs.stdenv.hostPlatform.system;
in {
  combine-blueprints = packagePythonScript {
    name = "combine-blueprints";
    src = ./combine-blueprints.py;
    version = "1.0.0";
    meta = {
      description = "Combine a directory of Factorio blueprints into a string";
      longDescription = ''
        Read the files generated by `export-blueprints` and combine them into a string
        that can be pasted into Factorio.
      '';
    };
  };

  command-palette = callPackage ./command-palette {};

  export-blueprints = packagePythonScript {
    name = "export-blueprints";
    src = ./export-blueprints.py;
    version = "1.0.0";
    meta = {
      description = "Export Factorio blueprints to a directory";
      longDescription = ''
        Export blueprints from ~/.factorio/blueprint-storage.dat to the repository.
        Each blueprint is saved as a separate file, should any fail to be exported,
        a list of failures and their traceback is saved to "errors.txt".

        All paths are hardcoded, as this is intended for this specific repository.

        Requires [factorio-blueprint-decoder](#factorio-blueprint-decoder) to be
        on the PATH.
      '';
    };
  };

  factorio-blueprint-decoder = let
    src = inputs.src-factorio-blueprint-decoder;
  in
    packagePythonScript {
      name = "factorio-blueprint-decoder";
      src = "${src}/decode";
      version = "unstable";
      meta = {
        description = "Decode a Factorio blueprint storage file";
        longDescription = ''
          Decode a Factorio blueprint storage file into plain JSON on stdout.
          This should be considered highly unstable, and may break at any time
          or for any reason, but is designed to error out instead of producing
          invalid output.
        '';

        homepage = "https://github.com/kieranknowles1/factorio-blueprint-decoder/tree/turret_fix";
      };
    };

  # TODO: Use callPackage everywhere
  # TODO: Use an overlay to remove the need for the `inputs` argument and others
  nixvim = callPackage ./nixvim {inherit inputs;};

  openmw-dev = let
    latestSrc = pkgs.fetchFromGitLab {
      owner = "OpenMW";
      repo = "openmw";
      # Master as of 22-08-2024
      rev = "03e8b8db0df9bfd97f4db22ead770568c6e8d206";
      hash = "sha256-HTPyQz9e6HCsrPab0Wbi7FZJwoQvt8jJNqComYkWIWs=";
    };

    devPkg = inputs.openmw.packages.${system}.openmw-dev;
  in
    devPkg.overrideAttrs (oldAttrs: {
      src = latestSrc;
    });

  openmw-luadata = callPackage ./openmw-luadata {};

  rebuild = callPackage ./rebuild {};

  resaver = pkgs.writeShellApplication {
    name = "resaver";
    runtimeInputs = with pkgs; [
      jq
      jdk21
    ];

    text = builtins.readFile ./resaver.sh;

    meta = {
      description = "Skyrim and Fallout 4 savegame editor";
      longDescription = ''
        A savegame editor for Skyrim and Fallout 4, wrapped to be fetched automatically
        from Nexus Mods with an API key.

        The first time the script is run, it will download the JAR file from Nexus Mods. Subsequent
        calls will use the cached file.

        # Prerequisites
        The API key of a premium Nexus Mods account must be stored at `~/.config/sops-nix/secrets/nexusmods/apikey`.
      '';

      mainProgra = "resaver";
    };
  };

  set-led-state = callPackage ./set-led-state {};

  skyrim-utils = callPackage ./skyrim-utils {};

  spriggit = callPackage ./spriggit.nix {};
}
