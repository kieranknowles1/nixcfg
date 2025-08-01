$env.config.show_banner = false

# Suggest updating Nixpkgs at least this often
const NIXPKGS_UPDATE_SUGGESION = 2wk

def __log [color: string, type: string, message: string] {
  print $"(ansi $color)($type)(ansi reset): ($message)"
}

alias "log info" = __log "blue" "Info"
alias "log warn" = __log "yellow" "Warning"
alias "log error" = __log "red" "Error"

# === Commands and Aliases ===

alias void = ignore
alias discard = ignore

# Split a string on newlines, like Bash's `read`
def "from lines" []: string -> list<string> {
    split row "\n"
}

# Get the size of the current Git checkout, excluding any ignored files
def repodu [
    repo: path = "."
] {
    cd $repo
    let files = git ls-files | from lines
    ls **/* | where name in $files | get size | math sum
}

def sizediff [
    a: path
    b: path
] {
  (ls $a | get 0.size) - (ls $b | get 0.size)
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

# List all installed Zed extensions, in a form that can be
# copied into the "auto_install_extensions" field of the Zed config
def list-zed-extensions [] {
  let installed = (ls ~/.local/share/zed/extensions/installed
        | get name | path parse | get stem
        # Transform from a list of strings to a JSON object
        # in the form {"extension-name": true}
        | each {{$in: true}} | into record)

  let desired = open ~/.config/zed/settings.json | get auto_install_extensions

  if ($installed != $desired) {
    log warn "Zed extensions do not match auto_install. Change value in settings.json to:"
    print ($installed | to json)
  } else {
    log info "Zed extensions match auto_install"
  }
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

    let ago = (date now) - $nixpkgs_timestamp

    print $"Welcome to (ansi green)Nushell(ansi reset)!"
    print $"Nixpkgs was last updated (ansi cyan)($last_update_relative)(ansi reset)."

    if ($ago > $NIXPKGS_UPDATE_SUGGESION) {
      log info "It may be time to update your Nixpkgs!"
    }
}

# Show a welcome message unless we're in a sub shell
if not ($env.__NU_INIT? | default false | into bool) {
    __show_welcome_message
    $env.__NU_INIT = true
}
