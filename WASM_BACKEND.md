# The wasm backend

This fork of Odin has a second code generator: `-backend:wasm` emits a
WebAssembly module directly from the checked program, with no LLVM and no
linker, for the `freestanding_wasm32`, `js_wasm32` and `wasi_wasm32` targets.
The compiler itself can be built without LLVM and as a WASI module, which is
how the [Karl2D Playground](https://karl2d.com/playground) compiles Odin in the
browser. Everything else in the repository is upstream Odin, kept in sync with
`odin-lang/Odin` master; this document is what someone needs to keep it that
way.

## What is where

The backend is `src/wasm_backend*.cpp`, about 20,000 lines, included from
`src/main.cpp` as one unit like the rest of the compiler:

| File | What it does |
|---|---|
| `wasm_backend.hpp` | The data structures: module, procedure, values, the instruction set |
| `wasm_backend.cpp` | Driver, calling convention (`ProcCC_Odin` returns up to eight scalars as wasm multi-values, everything else through memory), globals, constants, `__odin_wasm_startup` |
| `wasm_backend_emit.cpp` | Instruction encoding |
| `wasm_backend_opt.cpp` | The optimiser: copy propagation, dead stores, slot promotion, bounds check elimination, inlining, peepholes; runs on every procedure |
| `wasm_backend_expr.cpp` | Expressions, conversions, builtins (`wb_build_builtin_call_internal`), 128-bit integers, endian-specific scalars |
| `wasm_backend_stmt.cpp` | Statements, control flow, `for` over ranges and containers, `switch`, `defer`, the bounds-check-elimination analysis of loops |
| `wasm_backend_rtti.cpp` | Type information, mirroring `Type_Info` in `base/runtime/core.odin` |
| `wasm_backend_map.cpp` | Maps, mirroring `base/runtime/dynamic_map_internal.odin` |
| `wasm_backend_soa.cpp` | `#soa` arrays, mirroring `base/runtime/core_builtin_soa.odin` |
| `wasm_backend_simd.cpp` | `#simd` vectors and the `simd_*` intrinsics, lane by lane |
| `wasm_backend_atomic.cpp` | Atomics (single threaded: plain loads and stores with the right widths) |
| `wasm_backend_link.cpp` | Linking in wasm object files from `foreign import` (the `vendor` libraries ship `*_wasm.o`) |

Outside those files the fork touches upstream in a few small places, all of
which a merge can collide with: `src/main.cpp` (the `-backend:wasm` flag and
running wasm outputs through `wasmtime` for `odin run`/`odin test`, with
`ODIN_WASM_RUNTIME` and `ODIN_WASM_RUNTIME_FLAGS`), `src/build_settings.cpp`
(`Backend_Wasm`, `-wasm-lower-all`), `src/checker.cpp`, and what it took to
build without LLVM and for WASI: `src/gb/gb.h`, `src/microarch.cpp`,
`src/common_memory.cpp`, `src/threading.cpp`, `src/path.cpp`,
`src/string_interner.cpp`, `src/bug_report.cpp`, `src/llvm_backend.cpp`
(`ODIN_NO_LLVM`). In `core`: `core/testing/runner_single_threaded.odin` and
`core/terminal/terminal_other.odin`. To see the whole footprint:

    git diff --stat $(git merge-base master upstream/master) master

Build scripts, at the root next to `build_odin.sh`:

- `build_odin_nollvm.sh` -- the compiler without LLVM; it can only generate code with `-backend:wasm`
- `build_odin_wasi.sh [debug|release]` -- the compiler as a WASI module (`odin.wasm`) with [wasi-sdk](https://github.com/WebAssembly/wasi-sdk) (`WASI_SDK=~/wasi-sdk`, `OUT=odin.wasm`); this is what the playground runs in the browser, so its size matters (about 3.7 MB, 1.06 MB gzipped)

Flags: `-backend:wasm` selects the backend; `-wasm-lower-all` lowers every
procedure of the packages being compiled, not only the reachable ones, which
is what the sweep below uses to find unsupported constructs.

## Building and testing

The native compiler is built like upstream (`./build_odin.sh release`, needs
LLVM); it has both backends, and the tests compare them against each other.
The tests need `wasmtime` on the `PATH` (and `wasm-ld` from LLVM for the
reference builds). The test material lives in `tests/wasm_backend/`, its
outputs in `tests/wasm_backend/out/` (ignored by git):

| Command | What it checks | Takes | Expected |
|---|---|---|---|
| `tests/wasm_backend/run.sh` | The differential harness: each `phase*` package built with both backends, run under wasmtime, outputs compared. New backend features get a test here | ~3 min | `160/160 passed` |
| `tests/wasm_backend/upstream_tests.sh [paths]` | Odin's own tests (`tests/internal` by default, `tests/core/*/` on request) through both backends, verdicts compared. **This is the first thing to run on anything upstream added or changed** | seconds per file | every line `same` |
| `tests/wasm_backend/sweep.sh` | Every core and vendor package lowered whole with `-wasm-lower-all` | ~10 min | `ok=221 fail=1 skipped=107` -- the failure is `vendor/box3d`, whose `box3d_wasm.o` lacks `b3InternalAssert` |
| `tests/wasm_backend/bench/run.sh` | Twelve benchmarks, LLVM `-o:speed` against the backend | ~1 min | see the table below |
| `./build_odin_wasi.sh release` | The compiler still builds without LLVM and for WASI (the merge may have added something `ODIN_NO_LLVM` has to exclude) | ~2 min | `odin.wasm` around 3.7 MB |
| karl2d.com: `playground/_source/test/run_all_examples.sh` | The 24 Karl2D examples compiled and run in a headless Firefox by the playground, on the new `odin.wasm` | ~8 min | `pass=24 fail=0` |

The benchmarks, in milliseconds under wasmtime, as of September 2026 (LLVM /
backend): bunnies 32 / 32, entities 21 / 23, matrix 46 / 45, map 159 / 113,
string_map 61 / 76, sort 1172 / 615, sort_struct 280 / 158, fib 10 / 15,
fmt 81 / 104, dyn_array 14 / 17, pixels 25 / 24, particles_soa 63 / 52. A row
that moves by a fifth or more after a change is a real change.

## Updating from upstream

The fork's `master` is upstream's `master` plus the backend. Upstream is
merged, not rebased; the merges have been clean because the backend is in its
own files, but everything upstream changes can still *mean* something for the
backend, and that is what the procedure is for.

Remotes: the fork is `https://github.com/karl-zylinski/wodin.git`, upstream is
`https://github.com/odin-lang/Odin.git`. In a fresh clone of the fork add
upstream as `upstream` (`git remote add upstream https://github.com/odin-lang/Odin.git`);
the checkout this was written in has them the other way round, upstream as
`origin` and the fork as `fork`, so read the names below for what they point at.

1. **See what came in.** `git fetch upstream` and then

       git log --oneline master..upstream/master
       git diff --stat master...upstream/master

   Sort the files into: the compiler (`src/`), the runtime (`base/`), the
   library (`core/`, `vendor/`), and upstream's tests (`tests/`). The last
   group is the gift: a new or changed `tests/internal/*.odin` is a ready-made
   check of exactly the thing that changed.

2. **Merge.** `git merge upstream/master`. A conflict can only be in the
   handful of upstream files the fork touches (listed above); resolve keeping
   both sides' intent. Then `./build_odin.sh release`.

3. **Run the harness** (`tests/wasm_backend/run.sh`) and **the upstream tests
   that changed**:

       tests/wasm_backend/upstream_tests.sh $(git diff --name-only ORIG_HEAD master -- tests/internal)

   or all of `tests/internal` -- it is quick. `DIFFER` means the backend does
   not do what LLVM does for something upstream cared enough about to test.

4. **Read the compiler and runtime changes with the backend in mind.** The
   backend does not link against anything; it *mirrors* things, and every
   mirror can go stale. What to look for, and where it lands:

   | Upstream changed | Look at | Because |
   |---|---|---|
   | `src/checker_builtin_procs.hpp` -- a new `BuiltinProc_*` | `wb_build_builtin_call_internal` in `wasm_backend_expr.cpp`; `wasm_backend_simd.cpp` for `simd_*` | Every builtin the checker accepts needs a case, or the sweep reports "unsupported builtin" |
   | `src/llvm_backend_proc.cpp`, `src/llvm_backend_*.cpp` -- semantics of a builtin or an operation | The same operation in the backend | The LLVM backend is the reference; when its meaning changes (`simd_abs` of unsigned lanes, `simd_select` masks, saturation, poison) the backend must follow. `upstream_tests.sh` on the test that came with the fix tells you |
   | `src/types.cpp` -- a new `Type_*` kind or a change to a type's layout | `wasm_backend_rtti.cpp`, `wb_valtype_of`, `wb_abi_flatten`, conversions in `wasm_backend_expr.cpp` | Size, alignment, how it is passed and returned, how `type_info_of` describes it |
   | `base/runtime/core.odin` -- `Type_Info*`, `Raw_*`, `Source_Code_Location`, `Context`, allocator modes | `wasm_backend_rtti.cpp`, the struct offsets in `wasm_backend.cpp`/`_expr.cpp` | The backend writes these structures into memory by hand, field by field |
   | `base/runtime/dynamic_map_internal.odin` | `wasm_backend_map.cpp` | Map layout, hashing, the procedures called by name (`map_insert_hash_dynamic`, `__dynamic_map_check_grow`, ...) |
   | `base/runtime/core_builtin_soa.odin`, `core_builtin.odin` | `wasm_backend_soa.cpp`, `wasm_backend_expr.cpp` | `#soa` layout, `append`/`reserve` (`__dynamic_array_append`, ...) |
   | Anything renaming a runtime procedure | `grep -o 'wb_emit_runtime_call(p, "[a-z_0-9]*"' src/wasm_backend*.cpp` and `wb_lookup_runtime_procedure` | The backend calls about twenty runtime procedures by name: `bounds_check_error`, `default_hasher*`, `cstring_to_string`, `memory_equal`, `__type_info_of`, `extendhfsf2`/`truncsfhf2` for f16, ... A rename shows up as "runtime procedure not found" at the first program that needs it |
   | `src/parser.hpp` -- `AST_KINDS`, a new node or field | `wasm_backend_stmt.cpp`, `wasm_backend_expr.cpp` | The backend switches on node kinds; a new kind that reaches it is an "unsupported statement/expression" |
   | `src/check_expr.cpp`, `src/check_stmt.cpp` -- new constant folding, new implicit conversions, new `ExactValue` kinds | `wb_const` in `wasm_backend.cpp` | Constants are emitted from `ExactValue`; a new kind or a new place a constant can appear (`#location` in a global initialiser, say) hits `wb_const`/`wb_write_const_data` |
   | `src/entity.cpp`, `src/checker.cpp` -- entity flags, `@(...)` attributes | `wasm_backend.cpp` procedure setup | Calling convention, `#force_inline`, `@(export)`, `@(link_name)`, `foreign` |
   | `core/sys/wasm/js/*`, `base/runtime/os_specific_js.odin`, `os_specific_wasi.odin` | Nothing in the backend, but the playground: `odin.js` is copied from `core/sys/wasm/js/odin.js` at build | The runtime the compiled programs run on in the browser |
   | `src/check_asm.cpp`, `src/asm_tables*.cpp` | Nothing -- the backend has no inline assembly | But they are compiled into `odin.wasm` and are the main reason it grows |

   Changes to `core` in general need no backend work: the sweep compiles all
   of it and says so if it does.

5. **Run the rest**: the sweep, the WASI build, the benchmarks, and the
   playground's examples against the new `odin.wasm` (build the playground with
   `ODIN_WASM=path/to/odin.wasm` to skip the wasi-sdk build; see the
   [playground README](https://github.com/karl-zylinski/karl2d.com/tree/master/playground/_source)).
   Compare against the expected results above. Note the size of `odin.wasm`
   gzipped; the compiler downloads on every playground visit.

6. **Fix what the tests found**, add a test to `tests/wasm_backend/` for it
   (a `phase*` package; `calls.txt` for exported procedures compared one call
   at a time, or a `main` whose output is compared), and run the harness
   again. Then commit the merge and the fixes, `git push` to the fork's
   `master`.

7. **Deploy.** karl2d.com rebuilds the playground from the fork's `master`
   within the hour by itself (its deploy workflow polls both repositories),
   or at once with `gh workflow run Deploy --repo karl-zylinski/karl2d.com`.
   `https://karl2d.com/playground/build.json` says which commits the live
   site was built from.

## What a merge has needed so far

For the record, and as a sense of what to expect:

- 31 commits of inline-assembly work, `type_elem_type` for fixed-capacity
  dynamic arrays, `core:fmt` on named returns: nothing. The asm AST changed
  shape completely and the backend never looks at it.
- `simd_abs` fixed for unsigned lanes upstream: the backend already did it
  right, but the test upstream added (`test_abs.odin`) failed 8 checks under
  the backend for a different reason -- `abs`, `min`, `max` and `clamp` of an
  `f32be`/`f64be` variable ran on the byte-swapped local. Fixed in
  `wasm_backend_expr.cpp`, covered in `phase3_endian`. This is the pattern:
  the upstream test is worth more than the upstream diff.
