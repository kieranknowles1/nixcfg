#!/usr/bin/env bash
set -euo pipefail

# Install Godot export templates for building in the editor
# Does not install templates for cross-compilation
# Resulting builds will not work on non-NixOS systems

templates="$(nix build nixpkgs#godot_4.export-template --no-link --print-out-paths)"
ln -s "$templates/share/godot/export_templates" ~/.local/share/godot/export_templates
