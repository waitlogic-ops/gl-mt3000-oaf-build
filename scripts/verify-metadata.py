#!/usr/bin/env python3
import os
import pathlib
import re
import sys

text = pathlib.Path(sys.argv[1]).read_text()
dependency = f'kernel={os.environ["EXPECTED_KERNEL"]}~{os.environ["EXPECTED_ABI"]}-r1'
found = re.findall(r'kernel=[^\s\]\",]+', text)
if found != [dependency]:
    raise SystemExit(f'APK dependency mismatch: expected {dependency!r}, found {found!r}')
print(f'Verified APK dependency: {dependency}')
