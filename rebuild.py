#!/usr/bin/env python3

from argparse import ArgumentParser, Namespace
from subprocess import run
from os import geteuid

class Arguments:
    class NoCommit:
        # More explicit to say "NoCommit means not committing" than "None means no message and not committing if no message"
        pass

    @staticmethod
    def from_cli():
        parser = ArgumentParser(description="Rebuilds the system from the current repository state and commits the changes if successful.")

        # Require exactly one of these arguments. Checks are done later.
        parser.add_argument("message", help="The commit message.", nargs="?")
        parser.add_argument("-C", "--no-commit", action="store_true", help="Don't commit the changes.")

        parser.add_argument("-u", "--update", action="store_true", help="Update flake inputs before rebuilding.")

        return Arguments(parser.parse_args())

    def __init__(self, args: Namespace):
        if args.message is None and not args.no_commit:
            raise ValueError("A commit message is required when committing changes.")
        elif args.message is not None and args.no_commit:
            raise ValueError("A commit message cannot be provided when not committing changes.")

        self.message: str|Arguments.NoCommit = args.message if not args.no_commit else Arguments.NoCommit()
        self.update: bool = args.update # TODO: Implement this

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
    """Get the generation number, build timestamp, etc. of the active configuration."""

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

    if arguments.message is not Arguments.NoCommit:
        generation_meta = get_generation_meta()

        # Commit the changes. Multiple -m options will be concatenated, each as a separate paragraph
        run(["git", "add", "."], check=True)
        run(["git", "commit",
            "-m", f"{generation_meta.number}: {arguments.message}",
            "-m", generation_meta.meta,
            "-m", diff], check=True)

if __name__ == "__main__":
    main()
