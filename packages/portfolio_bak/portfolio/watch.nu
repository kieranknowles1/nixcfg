#!/usr/bin/env nu

def rebuild [] {
    nix build .#portfolio
}

def notify [] {
    pw-cat -p ~/Documents/src/csc8508-team-project/Assets/Audio/jump.wav
}

# Watch src directory, and rebuild when a change is detected
def main [] {
    rebuild
    # We need to start Firefox with a URL, rather than using
    # xdg-open otherwise we'll be pointing to the Nix store
    # rather than the symlink, which won't be updated after
    # rebuilds.
    firefox $"file://(pwd)/result/index.html"
    watch src {
        rebuild
        notify
        print "Rebuild complete, please refresh."
    }
}
