#!/usr/bin/env bash
# Lowers every procedure of every core and vendor package with the wasm backend,
# including the ones no program calls (-wasm-lower-all), to find constructs the
# backend does not handle yet. Nothing is run: a package passes when it builds
# and the compiler neither reports a "wasm backend" error nor asserts.
#
# Packages that cannot be built for a wasm target at all -- bindings to an
# operating system or a native library, tools, tests -- are listed in
# sweep_skipped.txt, one directory per line, relative to the repository root.
#
# Usage: tests/wasm_backend/sweep.sh            (from anywhere)
#   ODIN   the compiler under test (default: ./odin at the repository root)
#
# Prints one summary line; the failures, with the first lines of what the
# compiler said about each, end up in tests/wasm_backend/out/sweep/errs.txt.
# The one expected failure is vendor/box3d, whose prebuilt box3d_wasm.o does
# not define b3InternalAssert.
set -u

here=$(cd "$(dirname "$0")" && pwd)
cd "$here/../.."
ODIN=${ODIN:-./odin}
export ODIN_ROOT=$(pwd)
OUT="$here/out/sweep"
mkdir -p "$OUT"
: > "$OUT/errs.txt"

ok=0; fail=0; skipped=0
for d in $(find core vendor -name '*.odin' -printf '%h\n' | sort -u); do
	if grep -qx "$d" "$here/sweep_skipped.txt"; then
		skipped=$((skipped+1))
		continue
	fi
	out=$(timeout 300 "$ODIN" build "$d" -target:js_wasm32 -backend:wasm -no-entry-point -wasm-lower-all -out:"$OUT/sw.wasm" 2>&1)
	rc=$?
	if [ $rc -ne 0 ] || echo "$out" | grep -q "wasm backend\|Assertion"; then
		fail=$((fail+1))
		{ echo "== $d (exit $rc)"; echo "$out" | head -8; } >> "$OUT/errs.txt"
	else
		ok=$((ok+1))
	fi
done
echo "ok=$ok fail=$fail skipped=$skipped"
if [ $fail -gt 0 ]; then
	echo "failures in $OUT/errs.txt:"
	grep '^==' "$OUT/errs.txt"
fi
