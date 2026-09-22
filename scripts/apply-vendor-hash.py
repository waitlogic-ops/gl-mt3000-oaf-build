#!/usr/bin/env python3
"""Apply only the hash override explicitly requested by the user.

Keep the computed hash separately. This does not establish binary compatibility.
"""
import argparse
import os
import pathlib
import re
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("source", type=pathlib.Path)
parser.add_argument("--check", action="store_true")
args = parser.parse_args()
package_hash = os.environ["EXPECTED_ABI"]
if not re.fullmatch(r"[0-9a-f]{32}", package_hash):
    raise SystemExit("Invalid package hash")
relative = "include/kernel-defaults.mk"
original = subprocess.check_output(
    ["git", "-C", str(args.source), "show", f"HEAD:{relative}"], text=True
)
old = "\tgrep '=[ym]' $(LINUX_DIR)/.config.set | LC_ALL=C sort | $(MKHASH) md5 > $(LINUX_DIR)/.vermagic\n"
if original.count(old) != 1:
    raise SystemExit("Expected exactly one upstream hash-generation recipe")
new = old.replace("/.vermagic\n", "/.vermagic.native\n")
new += f"\techo '{package_hash}' > $(LINUX_DIR)/.vermagic\n"
expected = original.replace(old, new)
path = args.source / relative
if args.check:
    if path.read_text() != expected:
        raise SystemExit("Kernel recipe contains unexpected changes")
else:
    if path.read_text() != original:
        raise SystemExit("Refusing to replace existing kernel recipe edits")
    path.write_text(expected)
print(f"Package dependency hash override: {package_hash}; original hash preserved")
