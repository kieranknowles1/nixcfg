# Troubleshooting

Problems and solutions for various issues, not necessarily NixOS or even Linux
related (but mostly just NixOS).

- [Troubleshooting](#troubleshooting)
  - [Corrupt Derivation](#corrupt-derivation)
  - [Nerd Fonts not Working](#nerd-fonts-not-working)
  - [Minecraft Unable to Start](#minecraft-unable-to-start)
  - [Occasional Buzzing](#occasional-buzzing)

## Corrupt Derivation

Issue: When running a Nix command, such as `nh os build`, Nix will report an
error parsing a derivation such as:

```
error: error parsing derivation '/nix/store/bad-derivation.drv': error: expected string 'D'
```

In this instance, running `cat` showed the derivation to be an empty file.

Solution: run `nix-store --delete /nix/store/bad-derivation.drv` to remove the
corrupt file, which will be rebuilt the next time it is needed.

## Nerd Fonts not Working

Issue: Nerd Fonts icons, such as the `` (git branch icon) in the prompt, are
not displaying, instead showing as a box ▯.

Solution: Run `fc-cache --force` to update the font cache. After restarting the
terminal, the icons should display correctly.

## Minecraft Unable to Start

Issue: Minecraft fails to start with Prism reporting that it couldn't launch
after 3 tries.

Solution: Re-authenticate account under `Settings > Accounts`.

## Occasional Buzzing

Issue: In games, there will occasionally be a loud buzz, especially during lag
spikes.

Solution: Increase Pipewire's quantum via pw-metadata. Start at 256 and double
until the issue is resolved.
