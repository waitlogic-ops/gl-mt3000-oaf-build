#!/usr/bin/env bash
# Reproduce include/kernel-defaults.mk's .config.set calculation read-only.
# Report mismatches without stopping the user-requested actual compilation.
set -euo pipefail
cd openwrt
out=../evidence
configs=(target/linux/generic/config-6.12 target/linux/mediatek/filogic/config-6.12)
test ! -f target/linux/mediatek/config-6.12
scripts/kconfig.pl + "${configs[@]}" > "$out/kernel.config.target"
awk '/^(#[[:space:]]+)?CONFIG_KERNEL/{sub("CONFIG_KERNEL_","CONFIG_");print}' .config >> "$out/kernel.config.target"
printf '%s\n' '# CONFIG_KALLSYMS_EXTRA_PASS is not set' '# CONFIG_KALLSYMS_ALL is not set' 'CONFIG_KALLSYMS_UNCOMPRESSED=y' >> "$out/kernel.config.target"
scripts/package-metadata.pl kconfig tmp/.packageinfo .config 6.12 > "$out/kernel.config.override"
scripts/kconfig.pl 'm+' '+' "$out/kernel.config.target" /dev/null "$out/kernel.config.override" > "$out/kernel.config.merged"
grep -v INITRAMFS "$out/kernel.config.merged" > "$out/kernel.config.set.preflight"
printf '%s\n' 'CONFIG_INITRAMFS_SOURCE=""' '# CONFIG_INITRAMFS_FORCE is not set' '# CONFIG_INITRAMFS_PRESERVE_MTIME is not set' >> "$out/kernel.config.set.preflight"
actual=$(grep '=[ym]' "$out/kernel.config.set.preflight" | LC_ALL=C sort | md5sum | cut -d ' ' -f1)
cmp "$out/kernel.config.set.preflight" "$out/kernel.config.set.native"
test "$actual" = "$(cat "$out/kernel.vermagic.native")"
printf '%s\n' "$actual" | tee "$out/kernel-abi-preflight.txt"
test "$(cat "$out/kernel.vermagic.package")" = "$EXPECTED_ABI"
printf 'OpenWrt: %s\nKernel: %s\nPackage dependency hash (overridden): %s\nComputed configuration hash (original): %s\nUser-requested vendor hash workaround; hardware compatibility unverified.\n' "$OPENWRT_COMMIT" "$EXPECTED_KERNEL" "$EXPECTED_ABI" "$actual" | tee "$out/summary.txt" >> "$GITHUB_STEP_SUMMARY"
if [[ "$actual" != "$EXPECTED_ABI" ]]; then
  echo "::warning::Computed config hash differs from package hash. User-requested override is recorded; hardware compatibility remains unverified."
fi
