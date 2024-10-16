{
  flake.lib.shell = {
    /*
    Extended mkShell that uses the user's shell instead of bash

    # Arguments
    builder :: Function
    : The builder to use for the shell. Most commonly, `pkgs.mkShellNoCC` is used.

    args :: AttrSet
    : Arguments to pass to the shell builder

    Note that shellHook is executed as Bash, before execing the user's shell.
    */
    mkShellEx = builder: args:
      builder (args
        // {
          # args // passes all arguments to mkShellNoCC, except those that are overridden below

          # Our hook does the following:
          # - Run the hook passed to this function, if any
          # - Set DEVSHELL=1 for scripts that want to know if they're running in a devshell
          # - Replace Bash with the user's shell. The exec syscall replaces the current process,
          #   so Bash is not running and we only need to exit once to leave the devshell.
          shellHook = ''
            ${args.shellHook or ""}
            # Used to suppress our shell's welcome message
            export DEVSHELL=1

            # Replace Bash with the user's shell
            # Nix doesn't always preserve $SHELL, check for a default linked to by ~/.config/default-shell
            if [ -f ~/.config/default-shell ]; then
              export SHELL=$(readlink ~/.config/default-shell)
            fi
            exec "$SHELL"
          '';
        });
  };
}
