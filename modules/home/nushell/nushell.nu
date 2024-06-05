$env.config = {
    show_banner: false,
}

alias __orig_nix-shell = nix-shell
alias nix-shell = nix-shell --command "nu"
