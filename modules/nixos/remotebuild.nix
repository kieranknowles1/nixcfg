{lib, ...}: {
  config = {
    nix = {
      # Build derivations on remote machines if they are a better fit
      distributedBuilds = true;

      buildMachines = lib.singleton rec {
        system = "aarch64-linux";
        hostName = "tycho.local";
        sshUser = "kieran";
        sshKey = "/home/${sshUser}/.ssh/id_ed25519";
        maxJobs = 4;
      };

      settings = {
        # Allow remote builds to use cache.nixos.org
        builders-use-substitutes = true;
      };
    };
  };
}
