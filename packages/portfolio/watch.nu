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
    firefox $"file://(pwd)/result/index.html"
    watch src {
        rebuild
        notify
        print "Rebuild complete, please refresh."
    }
}
