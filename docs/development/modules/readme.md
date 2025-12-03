# Modules

The `modules` directory defines NixOS and home-manager modueles, and is where
the vast majority of config takes place. It contains the following
subdirectories:

- `home` home-manager modules
- `nixos` NixOS modules
- `shared` Modules loaded by both home-manager and NixOS, and fully compatible
  between the two.
- `modlib` Shared libraries used between multiple home-manager or NixOS modules.

If a shared library needs to differentiate between the two, they MUST take a
file-level `mode` argument that can be either `home` or `nixos`. These libraries
cannot be included in the top-level `flake.lib` due to module weirdness
(specialArgs and therefore `flake.lib` can't be used in options definitions, but
many of these functions are intended to be used there)

Subsections of this chapter document individual modules that require more
explanation.
