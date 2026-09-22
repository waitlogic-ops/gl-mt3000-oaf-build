#!/usr/bin/env python3
"""Extract IKCONFIG read-only from the pinned official GL.iNet package.

This is diagnostic evidence, not a replacement for corresponding kernel source.
The expanded .config is not the input that OpenWrt hashes for its package ABI.
"""
import hashlib
import pathlib
import sys
import zlib

source, destination = map(pathlib.Path, sys.argv[1:])
data = source.read_bytes()
expected = 'becf43031c16ee169bbd09f6ee7e5bee3caa4dabd24883e9ba70e436b84bbe0e'
if hashlib.sha256(data).hexdigest() != expected:
    raise SystemExit('Reference package SHA-256 differs from the inspected official copy')
if not data.startswith(b'ADBd'):
    raise SystemExit('Expected deflate-compressed APK v3')
adb = zlib.decompress(data[4:], -15)
if adb.count(b'IKCFG_ST') != 1:
    raise SystemExit('Expected exactly one IKCONFIG payload')
payload = adb.split(b'IKCFG_ST', 1)[1]
decoder = zlib.decompressobj(31)
config = decoder.decompress(payload)
if not decoder.eof or not decoder.unused_data.startswith(b'IKCFG_ED'):
    raise SystemExit('Truncated or invalid IKCONFIG payload')
if b'Linux/arm64 6.12.94 Kernel Configuration' not in config:
    raise SystemExit('Wrong reference kernel version/architecture')
destination.write_bytes(config)
print(f'{hashlib.sha256(config).hexdigest()}  {destination}')
