lib: mode:
let
  # Unfortunately, NixOS and home-manager use incompatible
  # syntax for systemd declarations, which keeps us from having
  # a simple shared module.
  # Most logic is therefore encapsulated here.
  inherit (lib) types mkOption;
  isNixos = mode == "nixos";

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

      schedule = mkOption {
        type = types.str;
        description = ''
          Schedule of the timer, expressed as a
          [systemd OnCalendar](https://www.freedesktop.org/software/systemd/man/systemd.time.html#Calendar%20Events)
        '';
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

      privateTmp = mkOption {
        type = types.bool;
        description = ''
          If true, the timer will use a private tmpfs mount.
        '';
        default = false;
      };
    }
    // (lib.optionalAttrs isNixos {
      user = mkOption {
        type = types.str;
        description = "User to run the timer as";
      };
    });
  };
in
{
  timerOpt = mkOption {
    type = types.attrsOf timerType;
    description = ''
      Systemd timers for recurring tasks.

      Acts as a wrapper to create a timer and a unit with a less verbose syntax.
    '';
    default = { };
  };

  timerBlock = cfg: {
    OnCalendar = cfg.schedule;
    Persistent = cfg.persistent;
  };

  serviceBlock =
    cfg:
    {
      Type = "oneshot";
      ExecStart = cfg.command;
      PrivateTmp = cfg.privateTmp;
    }
    // (lib.optionalAttrs isNixos {
      User = cfg.user;
    });
}
