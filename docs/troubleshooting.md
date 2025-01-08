# Troubleshooting

- [Troubleshooting](#troubleshooting)
  - [Nerd Fonts not Working](#nerd-fonts-not-working)

## Nerd Fonts not Working

Issue: Nerd Fonts icons, such as the `` (git branch icon) in the prompt, are
not displaying, instead showing as a box ▯.

Solution: Run `fc-cache --force` to update the font cache. After restarting the
terminal, the icons should display correctly.
