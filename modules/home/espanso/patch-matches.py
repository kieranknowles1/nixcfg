#!/usr/bin/env python3

import json
import yaml
from sys import argv, stderr

from typing import Any

def remove_keys(data: list[Any], remove: set[str]):
    filtered: list[Any] = []
    for match in data:
        if match["trigger"] not in remove:
            filtered.append(match)

    return filtered

def replace_values(data: list[Any], replace: dict[str, str]):
    for match in data:
        for key, value in replace.items():
            match["replace"] = match["replace"].replace(key, value)

def main():
    if len(argv) < 4:
        print(f"Usage: {argv[0]} <config> <in_file> <out_file>", file=stderr)
        exit(1)

    config = json.loads(argv[1])
    replace: dict[str, str] = config["replace"]
    remove: set[str] = set(config["remove"])
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
