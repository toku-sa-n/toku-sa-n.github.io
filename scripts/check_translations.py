#!/usr/bin/env python3

import os
import subprocess

translation_exts = [".en.body.md"]


def run_mdbook_transcheck(jp, translated):
    subprocess.run(["mdbook-transcheck", "-1", jp, translated], check=True)


def main():
    for root, dirs, files in os.walk("."):
        for file in files:
            for ext in translation_exts:
                if file.endswith(ext):
                    translated_path = os.path.join(root, file)
                    jp_path = translated_path.replace(ext, ".body.md")
                    run_mdbook_transcheck(jp_path, translated_path)


if __name__ == "__main__":
    main()
