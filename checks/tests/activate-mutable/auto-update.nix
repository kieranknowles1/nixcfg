{
  lib,
  pkgs,
  self,
  ...
}: let
  activate-mutable = lib.getExe self.packages.${pkgs.system}.activate-mutable;

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

    # Run 1: File A must be installed to home (hmf)
    runMutation ${configA.json} ${configA.file}
    # Run 2: New config with different config and different contents for hmf
    # hmf contents should be overwritten with File B as hmf starts with identical
    # contents to Config A's hmf spec
    runMutation ${configB.json} ${configB.file}

    # Run 3 & 4: activation should fail as hmf contents differ from both old
    # and new configs
    echo "Something new" >> $homeDir/test-file-write
    ! ${activate-mutable} activate ${configA.json} $homeDir
    ! ${activate-mutable} activate ${configB.json} $homeDir

    touch $out
  ''
