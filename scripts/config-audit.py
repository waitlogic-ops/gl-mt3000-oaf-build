#!/usr/bin/env python3
import pathlib
import sys

def read(path):
    return dict(line.split('=', 1) for line in pathlib.Path(path).read_text().splitlines()
                if line.startswith('CONFIG_') and '=' in line)

seed, resolved = map(read, sys.argv[1:])
for key, value in seed.items():
    if resolved.get(key) != value:
        print(f'{key}: official={value} resolved={resolved.get(key, "unset/unknown")}')
