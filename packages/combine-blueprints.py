#!/usr/bin/env python

# cSpell: words factorio

# Script to combine Factorio blueprints exported by `export-blueprints.py` into a blueprint string that can be imported into Factorio.

from base64 import b64encode
from os import listdir, path
from sys import argv
from typing import Any
import json
import zlib

BOOK_META_FILE = "book.json"
VERSION_IDENTIFIER = "0"

def read_json(file_path: str):
    with open(file_path, "r") as f:
        return json.load(f)

def read_book(book_dir: str):
    """
    Read a book that was split between multiple files
    """

    data = read_json(path.join(book_dir, BOOK_META_FILE))
    blueprints: list[Any] = []

    for item in listdir(book_dir):
        if item == BOOK_META_FILE:
            continue
        full_path = path.join(book_dir, item)

        if path.isdir(full_path):
            blueprints.append(read_book(full_path))
        else:
            blueprints.append(read_json(full_path))

    data["blueprint_book"]["blueprints"] = blueprints

    return data

def encode_blueprint_string(data: Any):
    """
    Encode an object in the Factorio blueprint string format
    """
    # https://wiki.factorio.com/Blueprint_string_format
    # A blueprint string consists of a version byte, followed by
    # zlib compressed JSON that is base64 encoded

    data_str = json.dumps(data)
    compressed_data = zlib.compress(data_str.encode(), level=9)
    encoded_data = b64encode(compressed_data).decode()

    return VERSION_IDENTIFIER + encoded_data


def main():
    if len(argv) != 2:
        print(f"Usage: {argv[0]} <blueprint_dir>")
        exit(1)
    path = argv[1]

    book = read_book(path)
    blueprint_string = encode_blueprint_string(book)

    print(blueprint_string)

if __name__ == "__main__":
    main()
