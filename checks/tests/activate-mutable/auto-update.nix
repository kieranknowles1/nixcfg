{lib, ...}: {
  perSystem = {
    self',
    pkgs,
    ...
  }: {
    checks.activate-mutable-auto-update = let
      activate-mutable = lib.getExe self'.packages.activate-mutable;

      mkConfig = contents: rec {
        file = pkgs.writeText "test-file" contents;
        json = pkgs.writeText "config.json" (builtins.toJSON [
          {
            source = file;
            destination = "test-file-write";
            onConflict = "warn";
          }
        ]);
      };

      configA = mkConfig "First test file";
      configB = mkConfig "Second test file";
    in
      pkgs.runCommand "activate-mutable-auto-update" {} ''
        homeDir=$(mktemp --directory)
        mkdir $homeDir/.config

        runMutation() {
          ${activate-mutable} activate $1 $homeDir
          echo "expect: current config written to home"
          cmp $homeDir/.config/activate-mutable-config.json $1
          echo "expect: current config's file written if unchanged from previous generation"
          cmp $homeDir/test-file-write $2
        }

        runMutation ${configA.json} ${configA.file}
        runMutation ${configB.json} ${configB.file}

        touch $out
      '';
  };
}
