def __telly [
    channel: string
]: nothing -> string {
    let choice = tv $channel
    if $choice == "" {
        error make {msg: "Cancelled"}
    }
    return $choice
}
def __tellyexec [channel: string, command: string] {
    run-external $command (__telly $channel)
}
# Fuzzy search and cd to a Git repository
def --env tvg [] { cd (__telly git-repos)}
# Fuzzy search and open a file, by its name
alias tvf = __tellyexec files $env.GUIEDITOR
# Fuzzy search and open a file, by its contents
alias tvc = __tellyexec text $env.GUIEDITOR
