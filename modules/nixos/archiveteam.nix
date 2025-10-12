{
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom.archiveteam = let
    inherit (lib) mkEnableOption;
  in {
    enable = mkEnableOption "ArchiveTeam Warrior";
  };

  config = let
    cfg = config.custom.archiveteam;
  in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = pkgs.stdenv.hostPlatform.isx86_64;
          message = ''
            ArchiveTeam Warrior requires a x86_64 architecture.
            See https://wiki.archiveteam.org/index.php/ArchiveTeam_Warrior#Can_I_run_the_Warrior_on_ARM_or_some_other_unusual_architecture?
            for more information.
          '';
        }
      ];

      virtualisation.oci-containers = {
        containers.archiveteam = {
          image = "atdr.meo.ws/archiveteam/warrior-dockerfile";
          ports = ["${builtins.toString config.custom.server.ports.tcp.archiveteam}:8001"];

          volumes = [
            "archiveteam-warrior-projects:/home/warrior/projects"
          ];
        };
      };
    };
}
