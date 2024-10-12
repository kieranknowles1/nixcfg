#!/usr/bin/env python3

# Let's use Python for this, since Bash is a horrible language for anything that isn't a one-liner

import json
import yaml
from sys import argv, stderr

from typing import Any

def remove_keys(data: list[Any], remove: set[str]):
    if len(remove) == 0:
        return data # Nothing to do

    filtered: list[Any] = []
    for match in data:
        if match["trigger"] not in remove:
            filtered.append(match)

    return filtered

def replace_values(data: list[Any], replace: dict[str, str]):
    if len(replace) == 0:
        return # Nothing to do

    for match in data:
        for key, value in replace.items():
            match["replace"] = match["replace"].replace(key, value)

def main():
    if len(argv) < 4:
        print(f"Usage: {argv[0]} <config> <in_file> <out_file>", file=stderr)
        exit(1)

    config = json.loads(argv[1])
    replace: dict[str, str] = config["replacements"]
    remove: set[str] = set(config["removals"])
    in_file = argv[2]
    out_file = argv[3]

    with open(in_file) as f:
        data = yaml.safe_load(f)

    data["matches"] = remove_keys(data["matches"], remove)
    replace_values(data["matches"], replace)

    with open(out_file, "w") as f:
        yaml.safe_dump(data, f)

if __name__ == '__main__':
    main()
