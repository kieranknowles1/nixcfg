$env.config = {
    show_banner: false,
}

alias __orig_nix-shell = nix-shell
alias nix-shell = nix-shell --command "DEVSHELL=1 nu"

def __get_nixpkgs_last_update [] {
    let flake = $env.FLAKE + "/flake.lock"
    let nixpkgs_utc_time = open $flake | from json | get nodes.nixpkgs-unstable.locked.lastModified

    # NuShell uses nanoseconds since epoch, while flake.lock uses seconds since epoch
    let nixpkgs_utc_nano = $nixpkgs_utc_time * 1_000_000_000
    let nixpkgs_timestamp = $nixpkgs_utc_nano | into datetime

    return $nixpkgs_timestamp
}

# Display our own welcome message
def __show_welcome_message [] {
    let nixpkgs_timestamp = __get_nixpkgs_last_update

    # Get a timestamp in the format "X days ago"
    let last_update_relative = $nixpkgs_timestamp | date humanize

    print $"Welcome to (ansi green)Nushell(ansi reset)!"
    print $"Nixpkgs was last updated (ansi cyan)($last_update_relative)(ansi reset)."
}

# Show a welcome message unless we're in a Nix shell
if not ($env.DEVSHELL? | default false | into bool) {
    __show_welcome_message
}
