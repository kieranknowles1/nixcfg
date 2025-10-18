{
  lib,
  config,
  ...
}: let
  inherit
    (import ../modlib/timerutil.nix lib "nixos")
    timerOpt
    timerBlock
    serviceBlock
    ;
in {
  options.custom.timer = timerOpt;

  config = let
    cfg = config.custom.timer;
  in {
    systemd.timers =
      builtins.mapAttrs (_name: timer: {
        inherit (timer) description;
        timerConfig = timerBlock timer;
        wantedBy = ["timers.target"];
      })
      cfg;

    systemd.services =
      builtins.mapAttrs (_name: timer: {
        inherit (timer) description;
        serviceConfig = serviceBlock timer;
      })
      cfg;
  };
}
