{
  lib,
  config,
  ...
}: let
  inherit
    (import ../modlib/timerutil.nix lib "home")
    timerOpt
    timerBlock
    serviceBlock
    ;
in {
  options.custom.timer = timerOpt;

  config = let
    cfg = config.custom.timer;
  in {
    systemd.user.timers =
      builtins.mapAttrs (_name: timer: {
        Unit.Description = timer.description;
        Timer = timerBlock timer;
        Install.WantedBy = ["timers.target"];
      })
      cfg;

    # A timer will automatically start any service with the same name.
    systemd.user.services =
      builtins.mapAttrs (_name: timer: {
        Unit.Description = timer.description;

        Service = serviceBlock timer;
      })
      cfg;
  };
}
