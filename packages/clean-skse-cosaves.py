#!/usr/bin/env python3

# cSpell: words skse skyrim

# Script to clean up leftover .skse co-save files from Skyrim Special Edition
# These files are useless when their corresponding .ess file is deleted, but SKSE64 doesn't clean them up

from os import listdir, remove, path

# TODO: Don't hardcode this, this is currently a symlink to MO2's actual profile. Probably use Nix or something
SAVE_DIR = path.expanduser("~/Documents/src/dotfiles/configs/games/skyrim/profile/saves")

def collect_saves() -> tuple[set[str], set[str]]:
    """
    Collect all .ess and .skse files in the save directory

    Returns
    -------
    tuple[set[str], set[str]]
        A tuple containing two sets of strings, the first containing all .ess files and the second containing all .skse files,
        all names excluding the file extension
    """

    ess_files: set[str] = set()
    skse_files: set[str] = set()

    for file in listdir(SAVE_DIR):
        if file.endswith(".ess"):
            ess_files.add(file.replace(".ess", ""))
        elif file.endswith(".skse"):
            skse_files.add(file.replace(".skse", ""))

    return ess_files, skse_files

def main():
    ess_files, skse_files = collect_saves()

    # Get a list of everything in skse_files that is not in ess_files
    to_delete = skse_files - ess_files

    if len(to_delete) == 0:
        print("Nothing to do")

    for file in to_delete:
        remove(path.join(SAVE_DIR, f"{file}.skse"))
        print(f"Deleted {file}.skse")

if __name__ == "__main__":
    main()
