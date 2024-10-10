_: {
  perSystem = {pkgs, ...}: {
    checks = {
      duplicate-input =
        pkgs.runCommand "check-duplicate-input" {
          nativeBuildInputs = with pkgs; [jq];
        } ''
          # Very simple check for duplicate inputs, Nix names these with _<number>, so we can just check for those
          # convention is to use hyphens, so this shouldn't have false positives
          dupes=$(cat ${./flake.lock} | jq '.nodes | with_entries(select(.key|match("_";""))) | keys[]')

          if [ ! -z "$dupes" ]; then
            echo "Duplicate inputs found:"
            echo "$dupes"
            exit 1
          fi

          touch $out # Needed for the check to pass
        '';
    };
  };
}
