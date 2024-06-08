#!/usr/bin/env python3

# Script to edit the configuration files for an application independently of NixOS,
# then copy them back to the source repository for version control

from argparse import ArgumentParser, Namespace
from os import readlink, remove, path
from shutil import copyfile, move
from subprocess import run

EDITOR = "code"
"""The editor of choice for config files."""
REPOSITORY = path.expanduser("~/Documents/src/nixcfg")
"""The path to the repository on disk."""

class Application:
    def __init__(self, system_path: str, repo_path: str):
        self.system_path = system_path
        """The path to the file on disk."""
        self.repo_path = repo_path
        """The path to the file relative to the repository."""

    def check_valid(self):
        """
        Check that all necessary conditions are met for editing the configuration file.
        """

        # The file MUST exist and MUST be a symbolic link
        if not path.exists(self.system_path):
            raise FileNotFoundError(f"File does not exist: {self.system_path}")

        if not path.islink(self.system_path):
            raise ValueError(f"File is not a symbolic link: {self.system_path}")

        # The file in the repository MUST exist
        if not path.exists(path.join(REPOSITORY, self.repo_path)):
            raise FileNotFoundError(f"File does not exist in repository: {self.repo_path}")

    def edit_config(self):
        # NixOS/Home Manager symlinks all its files, so we replace the symlink with a copy of the actual file
        self.check_valid()

        # Get the actual file path
        real_file = readlink(self.system_path)
        # Rebuilding the link would be a pain, so just move it out of the way
        link_backup = f"{self.system_path}.edit-config-link-backup"
        move(self.system_path, link_backup)

        # Replace the symlink with a copy of the actual file
        copyfile(real_file, self.system_path)


        run([EDITOR, self.system_path])
        print("Make your changes to the config file")
        # Code exits immediately when run from the command line, so we wait for additional input
        input("Press Enter to continue...")

        # Pull the changes back to the repository
        copyfile(self.system_path, path.join(REPOSITORY, self.repo_path))

        # Restore the symlink
        remove(self.system_path)
        move(link_backup, self.system_path)

        print("Changes pulled to repository")


# TODO: Don't hard code anything, we probably want to make this whole thing a home manager module
# then configure it in Nix
APPLICATIONS = {
    "code": Application(path.expanduser("~/.config/Code/User/settings.json"), "modules/home/vscode/settings.json"),
}

class Arguments:
    @staticmethod
    def from_cli():
        parser = ArgumentParser(description="Edit configuration files for an application and copy them back to the source repository")

        parser.add_argument("application", choices=APPLICATIONS.keys(), help="The application to edit the configuration file for")

        return Arguments(parser.parse_args())

    def __init__(self, args: Namespace):
        self.application: Application = APPLICATIONS[args.application]

def main():
    args = Arguments.from_cli()

    args.application.edit_config()

if __name__ == "__main__":
    main()
