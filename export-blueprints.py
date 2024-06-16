#!/usr/bin/env python

# cSpell: words factorio

# Script to export Factorio blueprints to the repository

DECODE = ["nix", "run", ".#factorio-blueprint-decoder"]
OUTPUT_DIR = "modules/home/games/factorio/blueprints"

from os import path, makedirs
from subprocess import run
from typing import Any
import json
from shutil import rmtree

def write_json(data: Any, path: str):
    print(f"Writing to {path}")
    with open(path, "w") as f:
        json.dump(data, f, indent=2)

def export_bin():
    result = run(
        DECODE + [path.expanduser("~/.factorio/blueprint-storage.dat")],
        check=True, capture_output=True, text=True
    )

    return json.loads(result.stdout)

def get_name(entry: dict[str, Any]) -> str:
    if "blueprint" in entry:
        return entry["blueprint"]["label"]
    elif "blueprint_book" in entry:
        return entry["blueprint_book"]["label"]
    elif "deconstruction_planner" in entry:
        return entry["deconstruction_planner"]["label"]
    elif "upgrade_planner" in entry:
        return entry["upgrade_planner"]["label"]
    else:
        raise ValueError(f"Unknown entry type: {entry.keys()}")

def dump_book(entry: dict[str, Any], base_dir: str, *, is_root: bool):
    """
    Dump a blueprint book and all its contents
    """
    name = get_name(entry)
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

    # Blueprint names can contain slashes, which would create subdirectories
    name = name.replace("/", "_")

    write_json(entry, path.join(base_dir, name + ".json"))

def dump_entry(entry: dict[str, Any], base_dir: str, *, is_root: bool):
    if "blueprint_book" in entry:
        dump_book(entry, base_dir, is_root=is_root)
    else:
        dump_generic(entry, base_dir)

def main():
    blob = export_bin()

    # The raw JSON is a bit large for Git, so we'll split it into smaller files by blueprint
    rmtree(OUTPUT_DIR) # Clear out the old data
    dump_entry(blob, OUTPUT_DIR, is_root=True)

if __name__ == "__main__":
    main()
