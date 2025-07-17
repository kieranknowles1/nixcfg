# Package to set the state of a keyboard LED, along with sudo
# rules to run it without a password
# We can't do this with just home-manager because the package
# requires sudo permissions to run
{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.custom.ledState;

  set-led-state = lib.getExe cfg.package;
in {
  options.custom.ledState = {
    enable = lib.mkEnableOption "run set-led-state without a password";

    package = lib.mkPackageOption pkgs.flake "set-led-state" {};
  };

  config = lib.mkIf cfg.enable {
    # Expanding when sudo is allowed is inherently risky, so we
    # be as specific as possible. That is:
    # - Only apply the rule to users who can already sudo
    # - Apply to the exact path in the nix-store, and no other
    # - Write the utility in Rust, and claim it was done for memory safety and not just because it's fun :)
    security.sudo.extraRules = [
      {
        groups = ["wheel"]; # Require that the user is allowed to sudo
        commands = [
          {
            command = lib.getExe cfg.package; # Apply to the set-led-state command
            options = ["NOPASSWD"]; # Don't require a password
          }
        ];
      }
    ];

    home-manager.sharedModules = lib.singleton {
      config.custom.shortcuts.hotkeys.keys = [
        {
          key = "slash";
          alt = true;
          # sudo doesn't require a password due to the rule defined above
          action = "sudo ${set-led-state} capslock off";
          description = "Turn off the Caps Lock LED";
        }
      ];
    };
  };
}
