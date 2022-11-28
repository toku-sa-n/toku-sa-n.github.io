#!/usr/bin/env python3

import os

lang_exts = ["", ".en"]  # "" for Japanese.


def assert_all_files_exist(basename):
    extensions = [".md", ".header.md", ".body.md"]
    for ext in extensions:
        if not os.path.isfile(basename + ext):
            print(basename + ext + " does not exist.")
            exit(1)


def check_file(basename):
    with open(basename + ".md") as output:
        s = ""
        with open(basename + ".header.md") as header:
            s = header.read()
        s += "\n"
        with open(basename + ".body.md") as body:
            s += body.read()
        if output.read() != s:
            print(basename + ".md is not up-to-date.")
            exit(1)


def main():
    for root, dirs, files in os.walk("."):
        for file in files:
            for ext in lang_exts:
                if file.endswith(ext + ".header.md"):
                    basename = os.path.join(root, file).replace(".header.md", "")
                    assert_all_files_exist(basename)
                    check_file(basename)


if __name__ == "__main__":
    main()
