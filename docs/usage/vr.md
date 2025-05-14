# VR Support

VR support is currently **EXTREMELY EXPERIMENTAL**. See
[vr.nix](../../modules/nixos/vr.nix) for implementation details.

## Current Status

It is currently possible to run the
[Godot XR Template](https://github.com/GodotVR/godot-xr-template), the start
screen will display in the headset with look direction tracking, but controllers
don't seem to work and I can't get past the start screen. `xrgears` works with
6dof, but no controllers are recognised.

SteamVR **DOES NOT WORK**, and fails to detect the headset.

## See Also

- [NixOS Wiki](https://wiki.nixos.org/wiki/VR)
- [Monado SteamVR](https://monado.freedesktop.org/steamvr.html) (haven't read
  this, but sounds interesting)
- [Monado Valve Index Setup](https://monado.freedesktop.org/valve-index-setup.html)
