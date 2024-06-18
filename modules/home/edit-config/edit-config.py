#!/usr/bin/env python3

# Script to edit the configuration files for an application independently of NixOS,
# then copy them back to the source repository for version control

from argparse import ArgumentParser, Namespace
from os import remove, path, listdir
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
                path.join(repository, app_data["repo-path"]),
                app_data.get("ignore-dirs"),
            )

class Application:
    BACKUP_EXTENSION = ".edit-config-backup"

    def __init__(self, system_path: str, repo_path: str, ignore_dirs: list[str]):
        self.system_path = system_path
        """The path to the directory on disk."""
        self.repo_path = repo_path
        """The path to the directory relative to the repository."""
        self.ignore_dirs = ignore_dirs
        """A list of directories to ignore when copying the configuration files. Only the top level is checked."""


    def check_valid(self):
        """
        Check that all necessary conditions are met for editing the configuration file.
        """

        # The system path MUST be a directory
        if not path.isdir(self.system_path):
            raise NotADirectoryError(f"Path is not a directory: {self.system_path}")

        # The repository path MUST be a directory
        if not path.isdir(self.repo_path):
            raise NotADirectoryError(f"Path is not a directory: {self.repo_path}")

    def _collect_links_recursive(self, relative_path: str, is_root: bool = False):
        full_repo_path = path.join(self.repo_path, relative_path)
        full_system_path = path.join(self.system_path, relative_path)

        if path.isdir(full_system_path):
            for file in listdir(full_system_path):
                if file in self.ignore_dirs:
                    continue

                yield from self._collect_links_recursive(path.join(relative_path, file))
        elif path.islink(full_system_path):
            if path.exists(full_repo_path):
                yield relative_path
            else:
                print(f"Warning: {relative_path} was marked for editing, but does not exist in the repository")
        else:
            print(f"Warning: {relative_path} is not a symlink")

    def collect_links(self):
        """
        Collect all symlinks that will be editable.

        Returns
        -------
        list[str]
            A list of all symlinks that will be edited, relative to both system_path and repo_path.
        """

        yield from self._collect_links_recursive("", is_root=True)
    
    def swap_links_with_repo(self, links: list[str]):
        for link in links:
            full_repo_path = path.join(self.repo_path, link)
            full_system_path = path.join(self.system_path, link)

            # Move the symlink out of the way
            move(full_system_path, full_system_path + self.BACKUP_EXTENSION)
            # Copy the file from the repository to the system
            copyfile(full_repo_path, full_system_path)
    

    def edit_config(self):
        # NixOS/Home Manager symlinks all its files, so we replace the symlink with a copy of the actual file
        self.check_valid()

        links = list(self.collect_links())

        # Rebuilding the link would be a pain, so just move it out of the way
        # changed_links = self.backup_links()
        self.swap_links_with_repo(links)

        # Replace the symlink with a copy of the file as it is in the repository
        # We don't want the version in the store as it may be out of date if
        # there are uncommitted changes
        # copyfile(self.repo_path, self.system_path)

        run([CONFIG.editor, self.system_path])
        print("Make your changes to the config file")
        # Code exits immediately when run from the command line, so we wait for additional input
        input("Press Enter to continue...")

        # Pull the changes back to the repository
        # TODO: Reimplement this
        # copyfile(self.system_path, self.repo_path)

        # Restore the symlink
        # remove(self.system_path)
        # move(link_backup, self.system_path)

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
