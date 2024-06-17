#!/usr/bin/env python3

from argparse import ArgumentParser, Namespace
from subprocess import run
from os import geteuid
from platform import node

class Arguments:
    @staticmethod
    def from_cli():
        """
        Parse arguments from the command line.

        Convention: Lowercase flags are for enabling features, uppercase flags are for disabling features. All
        flags must have a long form, if it's a disabling flag, it must be prefixed with "no-".
        """
        parser = ArgumentParser(description="Rebuilds the system from the current repository state and commits the changes if successful.")

        # The message is required unless we're not committing or are updating
        parser.add_argument("message", help="The commit message.", nargs="?")
        parser.add_argument("-C", "--no-commit", action="store_true", help="Don't commit the changes.")

        parser.add_argument("-D", "--no-diff", action="store_true", help="Don't include a diff in the commit message.")

        parser.add_argument("-u", "--update", action="store_true", help="Update flake inputs before rebuilding.")

        return Arguments(parser.parse_args())

    def __init__(self, args: Namespace):
        self.no_commit: bool = args.no_commit
        self.message: str|None = args.message
        self.diff: bool = not args.no_diff
        self.update: bool = args.update

        # Message may or may not be required, depending on the other arguments. Too complex for argparse on its own, so we handle it here.
        if self.message is None:
            # If we're not committing, we don't need a message
            if self.no_commit:
                pass
            # If we're updating, we can give a default
            elif self.update:
                self.message = "Update flake inputs."
            # Otherwise, we need a message
            else:
                raise ValueError("A commit message is required when not updating or committing changes.")

def called_as_root():
    return geteuid() == 0

def update_flake_inputs():
    """Update the flake inputs."""
    run(["nix", "flake", "update"], check=True)

def fancy_build():
    """Build the system with fancy progress and diff output. Uses the hostname as the build target."""
    run(["nh", "os", "build", "."], check=True)

def get_diff():
    """Get a diff between the repository state and the current system. Must be run before applying the configuration."""
    # Get a build symlinked into result/
    run(["nixos-rebuild", "build", "--flake", "."], check=True)
    # Generate a diff between the current system and the build
    return run(["nvd", "diff", "/run/current-system", "result/"], check=True, capture_output=True, text=True).stdout

def apply_configuration():
    """Apply the configuration to the system."""
    run(["sudo", "nixos-rebuild", "switch", "--flake", "."], check=True)

def get_generation_meta():
    """
    Get the generation number, build timestamp, etc. of the active configuration.
    NOTE: This may fail if there are too many generations and exit with an error.
    """

    # We only need the first two lines
    result = run(["nixos-rebuild", "list-generations"], check=True, capture_output=True, text=True).stdout.splitlines()[:2]

    meta = "\n".join(result)
    number = result[1].split()[0]

    class Result:
        def __init__(self, meta: str, number: str):
            self.meta = meta
            self.number = number
    return Result(meta, number)

def main():
    if called_as_root():
        raise RuntimeError("Do not run this script as root.")
    arguments = Arguments.from_cli()

    if arguments.update:
        update_flake_inputs()

    fancy_build()

    # We need to do this before applying the configuration, or we're just comparing the current system to itself
    diff = get_diff()

    apply_configuration()

    if not arguments.no_commit:
        generation_meta = get_generation_meta()
        host_name = node()

        commit_messages = [
            arguments.message or "Rebuild system.",
            f"{generation_meta.number}#{host_name}: {arguments.message}",
            generation_meta.meta,
        ] + ([diff] if arguments.diff else [])
        combined_message = "\n\n".join(commit_messages)

        # Commit the changes.
        run(["git", "add", "."], check=True)
        run(["git", "commit",
            "-m", combined_message], check=True)

if __name__ == "__main__":
    main()
