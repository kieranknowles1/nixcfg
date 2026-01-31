#!/usr/bin/env nu

def do_check [name: string, system: string] {
    nix build --no-link $".#checks.($system).($name)"
}

def list_checks [system: string] {
    nix flake show --json e> /dev/null | from json | get checks | get $system | columns
}

# Attempt to build the requested checks. If any check fails, then a non-zero
# exit code is returned, build logs are printed, and further checks are skipped.
def main [
    # Build all checks in the flake
    --all (-a)
    # List available checks, then exit
    --list (-l)
    # The checks to build
    ...targets: string
] {
    let system = nix eval --impure --raw --expr 'builtins.currentSystem'

    let targets = if $all or $list {
        list_checks $system
    } else {
        $targets
    }

    if $list {
        $targets
    } else {
        $targets | each {
            print $"Running check ($in)"
            do_check $in $system
        }
        print "All checks successful"
    }
}
