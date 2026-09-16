#!/usr/bin/env bash
# Runs Odin's own test suites through the wasm backend and through the LLVM
# backend, both built for wasi_wasm32 and run under wasmtime, and reports where
# the two disagree. tests/internal are the compiler's tests of itself: when
# upstream adds or changes one, running it here is the quickest way to learn
# whether the backend agrees with the reference -- and a disagreement points
# straight at what the backend has to catch up on.
#
# A test that fails the same way under both (one that needs an operating
# system, or inline assembly for another architecture) counts as "same": the
# question is only whether the backend behaves like the reference.
#
# Usage: tests/wasm_backend/upstream_tests.sh [path...]
#   path   a test file (run with -file) or a test package directory
#          default: every file in tests/internal
#          the big one: tests/wasm_backend/upstream_tests.sh tests/core/*/ tests/core/*/*/
#   ODIN      the compiler under test (default: ./odin at the repository root)
#   ODIN_REF  the compiler for the reference build (default: $ODIN; use an LLVM
#             build when ODIN was built with build_odin_nollvm.sh)
#
# Prints one line per path, "same" or "DIFFER", with the summary of each run,
# and exits non-zero when anything differed. The full output of every run is in
# tests/wasm_backend/out/upstream/.
set -u

here=$(cd "$(dirname "$0")" && pwd)
cd "$here/../.."
ODIN=${ODIN:-./odin}
ODIN_REF=${ODIN_REF:-$ODIN}
OUT="$here/out/upstream"
mkdir -p "$OUT"

# Both backends import the host math procedures from `env`, so the test binary
# needs them preloaded when the compiler runs it after the build
HOST_ENV="$OUT/host_env.wasm"
if ! "$ODIN" build "$here/host_env" -target:freestanding_wasm32 -backend:wasm -build-mode:dll -no-entry-point -out:"$HOST_ENV"; then
	echo "cannot build host_env"; exit 1
fi
export ODIN_WASM_RUNTIME_FLAGS="--preload env=$HOST_ENV"

if [ $# -eq 0 ]; then
	set -- tests/internal/*.odin
fi

# The line worth comparing: the runner's verdict, else the first error, else
# how the run ended. Timings are stripped, they never agree.
summary() {
	local line
	line=$(grep -m1 "^Finished\|Error:\|error:" "$1" | sed 's/ in [0-9.]*[a-zµ]*:/:/' | cut -c1-140)
	if [ -z "$line" ]; then
		line="exit $2"
	fi
	echo "$line"
}

differ=0
for path in "$@"; do
	path=${path%/}
	name=$(echo "$path" | tr '/.' '__')
	flag=""
	[ -f "$path" ] && flag="-file"
	timeout 900 "$ODIN_REF" test "$path" $flag -target:wasi_wasm32 -define:ODIN_TEST_FANCY=false -out:"$OUT/$name.ref.wasm" > "$OUT/$name.ref.log" 2>&1
	ref_rc=$?
	timeout 900 "$ODIN" test "$path" $flag -target:wasi_wasm32 -backend:wasm -define:ODIN_TEST_FANCY=false -out:"$OUT/$name.wasm" > "$OUT/$name.log" 2>&1
	rc=$?
	ref_sum=$(summary "$OUT/$name.ref.log" $ref_rc)
	sum=$(summary "$OUT/$name.log" $rc)
	if [ "$ref_sum" = "$sum" ] && [ $ref_rc -eq $rc ]; then
		printf "same    %-45s %s\n" "$path" "$sum"
	else
		differ=$((differ+1))
		printf "DIFFER  %-45s\n        ref:  %s\n        wasm: %s\n" "$path" "$ref_sum" "$sum"
	fi
done
echo "$# paths, $differ differ (logs in $OUT)"
[ $differ -eq 0 ]
