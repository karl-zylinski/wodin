package main

import "core:fmt"
import "base:intrinsics"

f32x4 :: #simd[4]f32
i32x4 :: #simd[4]i32
u8x16 :: #simd[16]u8
i16x8 :: #simd[8]i16

Packed :: struct #align(1) {
	pad: [17]u8,
	v:   f32x4,
	w:   f32x4,
}

Holder :: struct {
	v: u8x16,
}

Pos :: struct #packed {
	tag: u8,
	pos: [4]f32,
}

@(optimization_mode="none")
packed_sum :: proc(s: Packed) -> f32x4 {
	return s.v + s.w
}

@(optimization_mode="none")
holder_double :: proc(x: ^Holder) -> u8x16 {
	return x.v + x.v
}

@(optimization_mode="none")
transmute_sum :: proc(ps: []Pos) -> f32 {
	sum: f32x4
	for &p in ps {
		sum += transmute(f32x4)p.pos
	}
	v := transmute([4]f32)sum
	return v[0] + v[1] + v[2] + v[3]
}

print_f :: proc(name: string, v: f32x4) {
	a := transmute([4]f32)v
	fmt.println(name, a)
}

print_i :: proc(name: string, v: i32x4) {
	a := transmute([4]i32)v
	fmt.println(name, a)
}

main :: proc() {
	a := f32x4{1, -2, 3.5, 4}
	b := f32x4{0.5, 2, -1, 8}
	print_f("add", a + b)
	print_f("sub", a - b)
	print_f("mul", a * b)
	print_f("div", a / b)
	print_f("neg", -a)
	print_f("scalar", a * 2)

	x := i32x4{7, -9, 100, 3}
	y := i32x4{2, 4, -7, 3}
	print_i("add", x + y)
	print_i("sub", x - y)
	print_i("mul", x * y)
	print_i("and", x & y)
	print_i("or", x | y)
	print_i("xor", x ~ y)
	print_i("andnot", x &~ y)
	print_i("not", ~x)

	fmt.println("eq", a == a, a == b, x != y, x != x)
	nan := f32x4{0h7fc00000, 1, 2, 3}
	fmt.println("nan", nan == nan, nan != nan)
	z := f32x4{0, 1, 2, 3}
	nz := f32x4{-0.0, 1, 2, 3}
	fmt.println("zero", z == nz, z != nz)


	acc: f32x4
	for _ in 0..<3 {
		acc += a
	}
	acc *= b
	acc -= 1
	print_f("acc", acc)

	s: Packed
	s.v = {1, 2, 3, 4}
	s.w = {10, 20, 30, 40}
	print_f("packed", packed_sum(s))
	print_f("packed field", s.v * s.w)

	h: Holder
	for k in 0..<16 {
		arr := transmute([16]u8)h.v
		arr[k] = u8(k * 9)
		h.v = transmute(u8x16)arr
	}
	fmt.println("holder", transmute([16]u8)holder_double(&h))

	ps := []Pos{{1, {1, 2, 3, 4}}, {2, {10, 20, 30, 40}}, {3, {0.5, 0.25, 0.125, 1}}}
	fmt.println("transmute", transmute_sum(ps))

	q := i16x8{1, -2, 3, -4, 5, -6, 7, -8}
	r := q * q + q
	fmt.println("i16", transmute([8]i16)r)
	fmt.println("extract", intrinsics.simd_extract(a, 2), intrinsics.simd_extract(s.w, 3))
	fmt.println("lanes", intrinsics.simd_reduce_add_ordered(a + b))
	zs := f32x4{0, -0.0, 1, -2}
	fmt.println("neg zero", transmute([4]u32)(-zs), transmute([4]u32)(-(-zs)))
	za := [10]f64{}
	za[1] = -0.0
	fmt.println("neg array", transmute([10]u64)(-za))
}
