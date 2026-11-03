package main

import "core:fmt"
import "base:intrinsics"

f32x4 :: #simd[4]f32
f64x2 :: #simd[2]f64
M :: matrix[2, 2]f32

Key :: struct {
	m: M,
	v: f32x4,
	id: int,
}

simd_eq :: proc(x, y: $T) -> bool {
	a, b := x, y
	return intrinsics.type_equal_proc(T)(&a, &b)
}

main :: proc() {
	sm := make(map[f32x4]int)
	defer delete(sm)
	sm[{1, 2, 3, 4}] = 1
	sm[{4, 3, 2, 1}] = 2
	sm[{0, 0, 0, 0}] = 3
	sm[{-0.0, 0, -0.0, 0}] = 4
	fmt.println("simd len", len(sm), sm[{1, 2, 3, 4}], sm[{4, 3, 2, 1}], sm[{0, 0, 0, 0}])
	_, ok := sm[{1, 2, 3, 5}]
	fmt.println("simd missing", ok)

	dm := make(map[f64x2]int)
	defer delete(dm)
	dm[{0, 1}] = 1
	dm[{-0.0, 1}] = 2
	fmt.println("signed zero", len(dm), dm[{0, 1}])

	mm := make(map[M]int)
	defer delete(mm)
	mm[{1, 0, 0, 1}] = 42
	mm[{0, 1, 1, 0}] = 7
	mm[{1, 0, 0, 1}] = 43
	mm[{-0.0, 0, 0, 0}] = 5
	mm[{0, -0.0, 0, 0}] = 6
	fmt.println("matrix", len(mm), mm[{1, 0, 0, 1}], mm[{0, 1, 1, 0}], mm[{0, 0, 0, 0}])

	rm := make(map[#row_major matrix[3, 2]f32]int)
	defer delete(rm)
	rm[{1, 2, 3, 4, 5, 6}] = 1
	rm[{1, 2, 3, 4, 5, 7}] = 2
	fmt.println("row major", len(rm), rm[{1, 2, 3, 4, 5, 6}], rm[{1, 2, 3, 4, 5, 7}])

	km := make(map[Key]int)
	defer delete(km)
	km[{{1, 0, 0, 1}, {1, 2, 3, 4}, 1}] = 10
	km[{{1, 0, 0, 1}, {1, 2, 3, 4}, 2}] = 20
	km[{{-0.0, 0, 0, 1}, {1, 2, 3, -0.0}, 3}] = 30
	fmt.println("struct", len(km), km[{{1, 0, 0, 1}, {1, 2, 3, 4}, 1}], km[{{0, 0, 0, 1}, {1, 2, 3, 0}, 3}])

	nan := transmute(f32)u32(0x7fc00000)
	x := f32x4{nan, 1, 2, 3}
	y := f32x4{nan, 1, 2, 3}
	z := f32x4{-0.0, 1, 2, 3}
	w := f32x4{0, 1, 2, 3}
	fmt.println("equal proc", simd_eq(x, y), simd_eq(z, w), simd_eq(w, w))
	p := M{nan, 0, 0, 1}
	q := M{nan, 0, 0, 1}
	fmt.println("equal proc matrix", simd_eq(p, q), simd_eq(M{-0.0, 0, 0, 1}, M{0, 0, 0, 1}))
	fmt.println("operators", x == y, x != y, z == w, z != w)
	mz := M{-0.0, 0, 0, 1}
	mp := M{0, 0, 0, 1}
	fmt.println("matrix operators", p == q, p != q, mz == mp, mz != mp)
	k1 := Key{mz, z, 1}
	k2 := Key{mp, w, 1}
	k3 := Key{mp, z, 1}
	k4 := Key{mp, x, 1}
	k5 := k4
	fmt.println("struct operators", k1 == k2, k2 == k3, k3 != k2, k4 == k5, k4 != Key{mp, y, 1})
	arr1 := [2]f32x4{z, x}
	arr2 := [2]f32x4{w, x}
	fmt.println("array operators", arr1 == arr2, arr1[0] == arr2[0])
}
