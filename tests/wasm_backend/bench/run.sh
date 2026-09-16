#!/usr/bin/env bash
# Builds bench.odin with the LLVM backend at -o:speed (the reference) and with
# the wasm backend, runs both under wasmtime and prints the timings side by
# side. The wasm backend runs its own optimiser; the point of the comparison is
# to notice a regression in the code it generates, and to see how far it is
# from LLVM on each kind of work (loops over structs, maps, sorting, recursion,
# formatting, SoA).
#
# Usage: tests/wasm_backend/bench/run.sh      (from anywhere)
#   ODIN      the compiler under test (default: ./odin at the repository root)
#   ODIN_REF  the compiler for the reference build (default: $ODIN)
#
# Times move a few percent between runs; a change of a fifth or more in one
# row is real.
set -u

here=$(cd "$(dirname "$0")" && pwd)
cd "$here/../../.."
ODIN=${ODIN:-./odin}
ODIN_REF=${ODIN_REF:-$ODIN}
OUT="$here/../out/bench"
mkdir -p "$OUT"

"$ODIN_REF" build "$here" -target:wasi_wasm32 -o:speed -out:"$OUT/ref.wasm" || exit 1
"$ODIN" build "$here" -target:wasi_wasm32 -backend:wasm -out:"$OUT/wb.wasm" || exit 1

wasmtime run "$OUT/ref.wasm" > "$OUT/ref.txt" || exit 1
wasmtime run "$OUT/wb.wasm"  > "$OUT/wb.txt"  || exit 1

printf "%-16s %10s %10s %8s\n" "" "llvm ms" "wasm ms" "ratio"
paste "$OUT/ref.txt" "$OUT/wb.txt" | awk '
	$1 == "sink" { if ($2 != $4) print "sink differs: " $2 " vs " $4; next }
	{ printf "%-16s %10.2f %10.2f %8.2f\n", $1, $2, $5, ($2 > 0 ? $5 / $2 : 0) }
'
