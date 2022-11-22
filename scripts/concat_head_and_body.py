#!/usr/bin/env python3

import os

lang_exts = ["", ".en"]  # "" for Japanese.


def concat_file(basename):
    with open(basename + ".md", "w") as output:
        with open(basename + ".header.md") as header:
            output.write(header.read())
        output.write("\n")
        with open(basename + ".body.md") as body:
            output.write(body.read())


def main():
    for root, dirs, files in os.walk("."):
        for file in files:
            for ext in lang_exts:
                if file.endswith(ext + ".header.md"):
                    basename = os.path.join(root, file).replace(".header.md", "")
                    concat_file(basename)


if __name__ == "__main__":
    main()
