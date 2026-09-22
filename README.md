# GL-MT3000 OpenAppFilter kernel module build

**Current work: user-requested vendor hash workaround test build.**
The user supplied a GL.iNet reply recommending overriding the generated `.vermagic`
and explicitly requested this approach. `scripts/apply-vendor-hash.py` changes only
that recipe: it preserves the computed hash as `.vermagic.native` and writes
`9469a6c8c449c47e503c05678ea1559d` to `.vermagic` before compilation and packaging.
This supersedes the initial no-override build mode. The APK is a test build, not a
claim that the original config hash was reproduced or hardware compatibility proven.

Previous diagnostic result:
The [native configuration run](https://github.com/waitlogic-ops/gl-mt3000-oaf-build/actions/runs/35705066517)
successfully executed OpenWrt's original kernel configuration recipe and generated
`1f6665bb4c86de9e6929ce479d68f6da`, not the required
`9469a6c8c449c47e503c05678ea1559d`. The separate read-only preflight output was
byte-for-byte identical to the native `.config.set`. OAF compilation was therefore
not started and no APK was uploaded. The artifact contains diagnostic evidence only.

Target: GL.iNet 4.9.1-op25, OpenWrt 25.12.5, Linux 6.12.94,
kernel package ABI `9469a6c8c449c47e503c05678ea1559d`.

Build inputs:

- OpenWrt commit `f5dae5ece4805730c5e2850f8aa84765af2f6b32`.
- OpenAppFilter tag `v7.0.1`, commit `b88fcb082597486a816187ec1e02812082161d5e`.
- [GL.iNet staff's official MT3000 configuration](https://forum.gl-inet.com/t/4-6-6-op24-source-vermagic/50529/47).
- Original attachment: [official GL.iNet CDN](https://forum-static.gl-inet.com/original/3X/1/a/1a3e9e3633a2ccb67f94ad941a13f4eddcf8d7c7.zip).
  ZIP SHA-256: `5b119c87864c5776cdfcf20bdf04d24dc7539d720852b18fe0a8a631d2bc055e`.
  Extracted config SHA-256: `e0cfa93f51460d8b3c80e4799bb250bce4f4bd8f7d2d8cc3699930a525ee1da5`.
- Pinned OpenWrt release feeds plus public GL feed as of configuration publication.
  This public feed is a candidate, not an assertion of GL.iNet's private build inputs.

The workflow uses checksum-verified release host utilities/toolchain, builds the
kernel prerequisites with the supplied config, packages OAF's required in-tree module
dependencies, and builds OAF. It does not build a complete firmware image. No SDK
kernel configuration is imported. The vendor hash override patch is saved and checked
against the pinned upstream recipe; the computed config hash is independently verified.

`kmod-oaf-GL-MT3000-vendor-hash-test` contains the APK, `oaf.ko`, supplied/resolved build
configuration evidence, metadata, module information, checksums and the override patch.
`HASH-OVERRIDE-TEST-BUILD.txt` explicitly records both hashes and the unverified hardware
status. `build-evidence-*` contains detailed diagnostics, including any unverified output
retained after a failed verification. APK metadata must contain the exact requested
dependency `kernel=6.12.94~9469a6c8c449c47e503c05678ea1559d-r1`.

The user-supplied ZIP was checked against the official CDN copy and is byte-for-byte
identical (same SHA-256 above). Installation, loading and operation will be tested by
the user. No force-install flags or installed-database edits are used.

## Additional vendor evidence

`research/vendor-reference/provenance.json` records the exact official firmware and
official `kmod-ikconfig` package inspected. The extracted firmware confirms
4.9.1-op25 / r33051-f5dae5ece4 and the requested installed kernel package string.
`kernel-6.12.94.config` is the complete expanded kernel config extracted read-only
from the official feed's `configs.ko`. It is reference evidence, not a build input
and not the `.config.set` that OpenWrt hashes. Reproduce extraction with
`scripts/extract-reference-config.py` and the SHA-256-pinned reference package.

This reference config enables `CONFIG_SECURITY_GL_HW_CHECK=y`; the pinned public
OpenWrt source does not contain its Kconfig definition or implementation. GL.iNet's
public `gl-image` sources inspected provide this feature for other models with a
5.4 kernel, not a verified matching MT3000 6.12.94 patch set. The matching vendor
source/patch set, feed pins and original ABI-generation inputs or matching official
SDK are still needed. Replacing the ABI string alone would not establish compatibility
even when the override is explicitly requested as in this test workflow.
