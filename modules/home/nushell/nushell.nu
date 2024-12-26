$env.config.show_banner = false

# === Commands and Aliases ===
alias __orig_nix-shell = nix-shell
alias nix-shell = nix-shell --command "DEVSHELL=1 nu"

# Get the size of the current Git repository, excluding the .git directory
def repodu [
    repo: path = "."
] {
    let repo_size = du $repo | get 0.apparent
    let git_size = du $"($repo)/.git" | get 0.apparent
    $repo_size - $git_size
}

# Create a new directory and cd into it
def --env mkcd [
    name: string
] {
    mkdir $name
    cd $name
}

def __nix_path [
    repo: string
    target: string = "default"
] {
    $"($repo)#($target)"
}

# Enter a devshell for the specified repository
def dev [
    name: string = "default"
    --repo: string = "."
] {
    nix develop (__nix_path $repo $name)
}

# Enter a dev shell for the nixcfg repository
alias devr = dev --repo $env.FLAKE

# === Welcome Message ===
def __get_nixpkgs_last_update [] {
    let flake = $env.FLAKE + "/flake.lock"
    let nixpkgs_utc_time = open $flake | from json | get nodes.nixpkgs.locked.lastModified

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
