{
  lib,
  config,
  ...
}: {
  options.custom.timer = let
    inherit (lib) mkOption types;

    timerType = types.submodule {
      options = {
        description = mkOption {
          type = types.str;
          description = "Description of the timer";
        };

        command = mkOption {
          type = types.str;
          description = "Command to execute";
        };

        frequency = mkOption {
          type = types.str;
          description = "Frequency of the timer";
        };

        persistent = mkOption {
          type = types.bool;
          description = ''
            If a timer is missed due to the system being offline, should it be
            executed immediately on next boot?
          '';
          # On a desktop, most tasks will still be relevant after a reboot.
          default = true;
        };
      };
    };
  in
    mkOption {
      type = types.attrsOf timerType;
      description = ''
        Systemd timers for recurring tasks.

        Acts as a wrapper to create a timer and a unit with a less verbose syntax.
      '';
      default = {};
    };

  config = let
    cfg = config.custom.timer;
  in {
    systemd.user.timers =
      builtins.mapAttrs (_name: timer: {
        Unit.Description = timer.description;
        Timer = {
          OnCalendar = timer.frequency;
          Persistent = timer.persistent;
        };
        Install.WantedBy = ["timers.target"];
      })
      cfg;

    # A timer will automatically start any service with the same name.
    systemd.user.services =
      builtins.mapAttrs (_name: timer: {
        Unit.Description = timer.description;

        Service = {
          Type = "oneshot";
          ExecStart = timer.command;
        };
      })
      cfg;
  };
}
