{self, ...}: {
  perSystem = {pkgs, ...}: {
    checks = {
      duplicate-input = pkgs.runCommand "check-duplicate-input" {
        nativeBuildInputs = with pkgs; [jq];
        LOCK_FILE = "${self}/flake.lock";
      } (builtins.readFile ./duplicate-input.sh);
    };
  };
}
