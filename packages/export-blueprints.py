#!/usr/bin/env python

# cSpell: words factorio

# Script to export Factorio blueprints to the repository

OUTPUT_DIR = "modules/home/games/factorio/blueprints"

from os import path, makedirs
from shutil import rmtree
from subprocess import run
from sys import stderr
from typing import Any, Optional
import json

def write_json(data: Any, path: str):
    with open(path, "w") as f:
        json.dump(data, f, indent=2)

def export_bin():
    result = run(
        ["factorio-blueprint-decoder", path.expanduser("~/.factorio/blueprint-storage.dat"), "--skip-bad"],
        capture_output=True, text=True
    )
    print(result.stderr, file=stderr)

    skipped_any = result.returncode == 2
    if result.returncode != 0:
        if skipped_any:
            print("Warning: Some blueprints could not be decoded", file=stderr)
        else:
            print("Error: Failed to decode blueprints", file=stderr)

    return (json.loads(result.stdout), result.stderr if skipped_any else None)

def get_name(entry: dict[str, Any]) -> Optional[str]:
    if "blueprint" in entry:
        container = entry["blueprint"]
    elif "blueprint_book" in entry:
        container = entry["blueprint_book"]
    elif "deconstruction_planner" in entry:
        container = entry["deconstruction_planner"]
    elif "upgrade_planner" in entry:
        container = entry["upgrade_planner"]
    else:
        raise ValueError(f"Unknown entry type: {entry.keys()}")

    return container["label"] if "label" in container else None

def dump_book(entry: dict[str, Any], base_dir: str, *, is_root: bool):
    """
    Dump a blueprint book and all its contents
    """
    name = get_name(entry)
    if name is None:
        raise ValueError(f"Book at {base_dir} has no name")

    dir_path = path.join(base_dir, name) if not is_root else base_dir

    makedirs(dir_path, exist_ok=True)

    for item in entry["blueprint_book"]["blueprints"]:
        dump_entry(item, dir_path, is_root=False)

    # Write a metadata file containing everything relevant apart from its contents
    trimmed = entry.copy()
    del trimmed["blueprint_book"]["blueprints"] # Dumped separately
    if "active_index" in trimmed["blueprint_book"]: # Not present in the root book
        del trimmed["blueprint_book"]["active_index"] # Not relevant

    # The root book's label is just a timestamp, so use something static
    if is_root:
        trimmed["blueprint_book"]["label"] = "Root Blueprint Book"
        trimmed["blueprint_book"]["description"] = "Root book containing all other blueprints"

    write_json(trimmed, path.join(dir_path, "book.json"))

def dump_generic(entry: dict[str, Any], base_dir: str):
    """
    Dump an entry that doesn't require special handling
    """
    name = get_name(entry)
    if name is None:
        raise ValueError(f"Entry at {base_dir} has no name")

    # Blueprint names can contain slashes, which would create subdirectories
    name = name.replace("/", "_")

    write_json(entry, path.join(base_dir, name + ".json"))

def dump_entry(entry: dict[str, Any], base_dir: str, *, is_root: bool):
    if "blueprint_book" in entry:
        dump_book(entry, base_dir, is_root=is_root)
    else:
        dump_generic(entry, base_dir)

def main():
    blob, errors = export_bin()

    # The raw JSON is a bit large for Git, so we'll split it into smaller files by blueprint
    rmtree(OUTPUT_DIR) # Clear out the old data
    dump_entry(blob, OUTPUT_DIR, is_root=True)

    # If there were any errors, write them to a file to track in the commit
    if errors:
        with open(path.join(OUTPUT_DIR, "errors.txt"), "w") as f:
            f.write(errors)

if __name__ == "__main__":
    main()
