# Lessons Learned

Here are some mistakes I made and lessons learned while setting up this
repository, as well as incident reports from those "oh shit" moments. Be
prepared for strong language as I vent my mistakes.

## ~~Don't Use Wayland Yet~~ It's Not as Bad Now

Wayland is still quite buggy for me. I've had issues with flickering and Proton
games don't seem to work at all. Stick with X11 for now. Your choice will
persist between reboots.

Status June 2024: Wayland causes flickering in Skyrim when there's dropped
frames, which I think is due to double buffering. The issue occurs on both GNOME
Wayland and Hyprland. Stick with X11.

Status December 2025: It works well enough on Nvidia. Good thing since GNOME has
dropped X11 support. Anything to do with hotkeys, such as sxhkd and Espanso, is
broken and needs complete hacks to get working.

## INC01 Make Sure You Have a User

It's completely valid syntax to have a system without any usable users. Make
sure your config generates at least one and that they have a password set and
are in the `wheel` group to use `sudo`.

If you fucked up and can't log in, boot into a live NixOS environment and mount
both the root and boot partitions. Then, run `nixos-enter` to chroot into the
system. You can then fix the configuration and rebuild. If applying the config
fails, try setting your user's password anyway with `passwd <username>` and
rebooting into your main OS.

## INC02 Don't Mess with Bash

Messing too much with Bash can keep you from logging in. For example, setting
your `.bashrc` to exec a different shell will keep `home-manager` from
activating or graphical environments from starting even after rolling back.

Delete `.bashrc` and `.bash_profile` if they exist. This might not be enough for
reasons only the Bash gods know, so manually run `home-manager`'s activation
script over a SSH connection, since that still worked.

```sh
ssh hostname.local
# Find which derivation home-manager-generation is at
systemctl show home-manager-kieran.service | grep ExecStart
# Manually run the activation script
/nix/store/hash-of-home-generations-home-manager-generation/activate
```

## INC03 Backup Before You Troubleshoot

If something goes wrong, make sure to backup before performing any potentially
destructive actions. Forgejo was migrated to Postgres instead of SQLite, and
soon after the system was switched to a different branch for another feature,
that didn't have the Postgres commit.

To resolve the issue, I attempted to delete the Postgres database and recreate
it from the backup, not realising that Forgejo was trying to access the now
deleted SQLite database. Fortunately, this occurred only 2 hours after an
automatic backup meaning data loss was minimal.

## INC04 Don't Use the Standard Kernel on Raspberry Pi

Whilst waiting three hours for a kernel to build is annoying, it's better than
having no functioning kernel as happened when I tried to switch to the standard
kernel, which caused the system to fail to boot.

Recovering the system to the previous build required the following steps:

1. Mount the SD card on a functioning system.
2. Replace the various `/boot/firmware/nixos-kernels/default-*` files with the
   previous build's versions, prefixed with their generation number.
3. Replace `kernel.img` and `initrd` with the versions referenced by the
   previous generation.
4. Replace `systemConfig=/nix/store/` in `nixos-init` with whatever the previous
   generation used.
5. Replace the generation referenced in `cmdline.txt`, again with the previous
   generation's system derivation.
6. Pray it works, if not, rummage around for places I forgot to document and try
   again, or run a full-scale backup fire drill.
