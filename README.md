# GL-MT3000 OpenAppFilter kernel module build

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

The workflow rejects mismatched native configuration hashes before spending time
compiling. It builds tools, toolchain, kernel prerequisites and only the OAF package;
it does not build a complete firmware image. It checks the actual build hash again
and checks APK metadata before uploading any installable result. No hash override,
dependency rewriting, force install or installed-database modification is allowed.

`build-evidence-*` artifacts are diagnostics, **not successful installable output**.
Only `kmod-oaf-GL-MT3000-4.9.1-op25-9469a6c8` contains an APK that passed gates.
Hardware installation/loading remains a separate required validation step.

The user-supplied ZIP was checked against the official CDN copy and is byte-for-byte
identical (same SHA-256 above). Installation/loading will be tested by the user.
The workflow also runs the unmodified native `Kernel/Configure/Default` recipe and
compares its output to the preflight calculation. Release SDK host utilities and
compiler may be used for this diagnostic; no SDK kernel configuration is imported.
