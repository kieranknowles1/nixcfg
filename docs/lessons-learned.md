# Lessons Learned

Here are some mistakes I made and lessons learned while setting up this
repository, as well as recovery tips for those "oh shit" moments.

## Don't Use Wayland Yet

Wayland is still quite buggy for me. I've had issues with flickering and Proton
games don't seem to work at all. Stick with X11 for now. Your choice will
persist between reboots.

Status June 2024: Wayland causes flickering in Skyrim when there's dropped
frames, which I think is due to double buffering. The issue occurs on both GNOME
Wayland and Hyprland. Stick with X11.

## Don't Mess with Bash

Messing too much with Bash can keep you from logging in. For example, setting
your `.bashrc` to exec a different shell will keep `home-manager` from
activating or graphical environments from starting even after rolling back.

Delete `.bashrc` and `.bash_profile` if they exist. This might not be enough for
reasons only the Bash gods know, so manually run `home-manager`'s activation
script.

```sh
# Find which derivation home-manager-generation is at
systemctl show home-manager-kieran.service | grep ExecStart
# Manually run the activation script
/nix/store/hash-of-home-generations-home-manager-generation/activate
```

## Make Sure You Have a User

It's completely valid syntax to have a system without any usable users. Make
sure your config generates at least one and that they have a password set and
are in the `wheel` group to use `sudo`.

If you fucked up and can't log in, boot into a live NixOS environment and mount
both the root and boot partitions. Then, run `nixos-enter` to chroot into the
system. You can then fix the configuration and rebuild. If applying the config
fails, try setting your user's password anyway with `passwd <username>` and
rebooting into your main OS.
