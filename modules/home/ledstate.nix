{
  hostConfig,
  lib,
  ...
}: let
  cfg = hostConfig.custom.ledState;

  set-led-state = lib.getExe cfg.package;
in {
  config.custom.shortcuts.hotkeys.keys = lib.mkIf cfg.enable {
    "alt + slash" = {
      # sudo doesn't require a password due to the NixOS rule defined in [[../nixos/ledstate.nix]]
      action = "sudo ${set-led-state} capslock off";
      description = "Turn off the Caps Lock LED";
    };
  };
}
