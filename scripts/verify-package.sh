#!/usr/bin/env bash
set -euo pipefail
mapfile -t packages < <(find bin -name 'kmod-oaf-6.12.94-r1.apk')
test "${#packages[@]}" -eq 1
apk_file=${packages[0]}
apk_tool=$(find staging_dir/host/bin -name apk -type f -print -quit)
test -n "$apk_tool"
"$apk_tool" adbdump "$apk_file" > ../evidence/apk-metadata.txt
cat ../evidence/apk-metadata.txt
actual_abi=$(cat ../evidence/kernel.vermagic)
# Verify packaging preserves the compiler's native ABI; never rewrite it.
EXPECTED_ABI="$actual_abi" python3 ../scripts/verify-metadata.py ../evidence/apk-metadata.txt
if [[ "$actual_abi" != "$EXPECTED_ABI" ]]; then
  printf 'NOT VERIFIED COMPATIBLE: native ABI %s differs from device ABI %s.\nNo dependency overrides were applied.\n' "$actual_abi" "$EXPECTED_ABI" > ../dist/ABI-MISMATCH.txt
fi
module=$(find build_dir -path '*/oaf*/oaf.ko' -print -quit)
test -n "$module"
modinfo "$module" | tee ../evidence/oaf-modinfo.txt
test "$(modinfo -F vermagic "$module" | cut -d ' ' -f1)" = "$EXPECTED_KERNEL"
readelf -hSW "$module" > ../evidence/oaf-readelf.txt
grep -q AArch64 ../evidence/oaf-readelf.txt
grep -E 'oaf\.ko|MODPOST|oaf\.mod|LD \[M\]' ../evidence/oaf-build.log > ../evidence/oaf-build-key-lines.txt
git diff --exit-code -- include/kernel-defaults.mk include/kernel.mk include/package-pack.mk
sha256sum "$apk_file" "$module" > ../evidence/SHA256SUMS
cp "$apk_file" ../dist/
cp "$module" ../dist/oaf.ko
cp ../evidence/summary.txt ../evidence/apk-metadata.txt ../evidence/oaf-modinfo.txt ../evidence/SHA256SUMS ../dist/
