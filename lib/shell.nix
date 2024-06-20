{
  pkgs
}: {
  /**
    Extended mkShell that uses the user's shell instead of bash

    # Arguments
    Identical to mkShellNoCC. Note that shellHook is executed as Bash before exec'ing the user's shell.
   */
  mkShellEx = args: pkgs.mkShellNoCC (args // {
    # args // passes all arguments to mkShellNoCC, except those that are overridden below

    # Our hook does the following:
    # - Run the hook passed to this function, if any
    # - Set DEVSHELL=1 for scripts that want to know if they're running in a devshell
    # - Replace Bash with the user's shell. The exec syscall replaces the current process,
    #   so Bash is not running and we only need to exit once to leave the devshell.
    shellHook = ''
      ${args.shellHook or ""}
      export DEVSHELL=1
      exec "$SHELL"
    '';
  });
}
