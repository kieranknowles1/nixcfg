#!/usr/bin/env bash
exec nix develop "$FLAKE#$1"
