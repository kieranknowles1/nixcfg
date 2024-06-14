#!/usr/bin/env python3

# Script to edit the configuration files for an application independently of NixOS,
# then copy them back to the source repository for version control

from argparse import ArgumentParser, Namespace
from os import remove, path
from shutil import copyfile, move
from subprocess import run
import json

class Config:
    def __init__(self, file_path: str):
        with open(file_path) as f:
            data = json.load(f)

        self.editor: str = data["editor"]
        repository: str = path.expanduser(data["repository"])
        # Python list comprehensions can do this in one line, but the Python
        # developers were drunk so let's not do that
        self.applications: dict[str, Application] = {}
        for app, app_data in data["programs"].items():
            self.applications[app] = Application(
                path.expanduser(app_data["system-path"]),
                path.join(repository, app_data["repo-path"])
            )

class Application:
    def __init__(self, system_path: str, repo_path: str):
        self.system_path = system_path
        """The path to the file on disk."""
        self.repo_path = repo_path
        """The path to the file relative to the repository."""
        print(self.repo_path)

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
        if not path.exists(self.repo_path):
            raise FileNotFoundError(f"File does not exist in repository: {self.repo_path}")

    def edit_config(self):
        # NixOS/Home Manager symlinks all its files, so we replace the symlink with a copy of the actual file
        self.check_valid()

        # Rebuilding the link would be a pain, so just move it out of the way
        link_backup = f"{self.system_path}.edit-config-link-backup"
        move(self.system_path, link_backup)

        # Replace the symlink with a copy of the file as it is in the repository
        # We don't want the version in the store as it may be out of date if
        # there are uncommitted changes
        copyfile(self.repo_path, self.system_path)

        run([CONFIG.editor, self.system_path])
        print("Make your changes to the config file")
        # Code exits immediately when run from the command line, so we wait for additional input
        input("Press Enter to continue...")

        # Pull the changes back to the repository
        copyfile(self.system_path, self.repo_path)

        # Restore the symlink
        remove(self.system_path)
        move(link_backup, self.system_path)

        print("Changes pulled to repository")

CONFIG = Config(path.expanduser("~/.config/edit-config.json"))

class Arguments:
    @staticmethod
    def from_cli():
        parser = ArgumentParser(description="Edit configuration files for an application and copy them back to the source repository")

        parser.add_argument("application", choices=CONFIG.applications.keys(), help="The application to edit the configuration file for")

        return Arguments(parser.parse_args())

    def __init__(self, args: Namespace):
        self.application: Application = CONFIG.applications[args.application]

def main():
    args = Arguments.from_cli()

    args.application.edit_config()

if __name__ == "__main__":
    main()
