#!/usr/bin/env python

# cSpell: words factorio

# Script to export Factorio blueprints to the repository

from os import path, makedirs, walk
from shutil import rmtree
from subprocess import run
from sys import stderr, argv
from typing import Any, Optional
import json
import base64
import zlib


def write_json(data: Any, path: str):
    with open(path, "w") as f:
        json.dump(data, f, indent=2)


def export_bin():
    result = run(
        [
            "factorio-blueprint-decoder",
            path.expanduser("~/.factorio/blueprint-storage.dat"),
            "--skip-bad",
        ],
        capture_output=True,
        text=True,
    )
    print(result.stderr, file=stderr)

    # Return code:
    # 0: Ok
    # 2: One or more blueprints could not be decoded, described by stderr
    # Other: Fatal error
    skipped_any = result.returncode == 2
    if result.returncode != 0:
        if skipped_any:
            print("Warning: Some blueprints could not be decoded", file=stderr)
        else:
            raise Exception("Failed to decode blueprints")

    return (json.loads(result.stdout), result.stderr if skipped_any else None)

def decode_string(string: str):
    if string[0] != "0":
        raise ValueError("Invalid blueprint version")
    compressed = base64.b64decode(string[1:])
    unzip = zlib.decompress(compressed)

    print(f"Decoded {len(string)/1024:.2f} KB into {len(unzip)/1024:.2f} KB", file=stderr)

    return json.loads(unzip)

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
    del trimmed["blueprint_book"]["blueprints"]  # Dumped separately
    if "active_index" in trimmed["blueprint_book"]:  # Not present in the root book
        del trimmed["blueprint_book"]["active_index"]  # Not relevant

    # The root book's label is just a timestamp, so use something static
    if is_root:
        trimmed["blueprint_book"]["label"] = "Root Blueprint Book"
        trimmed["blueprint_book"][
            "description"
        ] = "Root book containing all other blueprints"

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


def check_output_dir(dir: str):
    """
    Check that no files exist in the output directory other than ones created by this script.

    If any unexpected files are found, raise a ValueError.

    Call before modifying the output directory.
    """

    for root, _dirs, files in walk(dir):
        for file in files:
            if not file.endswith(".json") and file != "errors.txt":
                raise ValueError(
                    f"Unexpected file in output directory: {path.join(root, file)}"
                )


def main():
    if len(argv) < 2:
        print(f"Usage: {argv[0]} <output_dir> <text=decode ~/.factorio/blueprint-storage.dat>", file=stderr)
        exit(1)
    out_dir = argv[1]

    check_output_dir(out_dir)

    if len(argv) < 3:
        blob, errors = export_bin()
    elif argv[2] == "text":
        # Dirty hack to let us paste more than 4096 characters into the terminal
        run(["nano", "/tmp/blueprint-string.txt"], check=True)
        with open("/tmp/blueprint-string.txt") as f:
            blob = decode_string(f.read())

        errors = None
    else:
        raise ValueError(f"Unknown argument: {argv[2]}")

    # The raw JSON is a bit large for Git, so we'll split it into smaller files by blueprint
    rmtree(out_dir)  # Clear out the old data
    dump_entry(blob, out_dir, is_root=True)

    # If there were any errors, write them to a file to track in the commit
    if errors:
        with open(path.join(out_dir, "errors.txt"), "w") as f:
            f.write(errors)


if __name__ == "__main__":
    main()
