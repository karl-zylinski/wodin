package main

import "base:intrinsics"
import "core:fmt"

Big :: struct {
	a, b, c, d: int,
	tag:        u8,
}

Padded :: struct {
	a: bool,
	b: int,
	c: [4]int,
}

Wide :: struct #align(64) {
	x: int,
}

@(align=4096) g_page: [64]u8
@(align=128)  g_a, g_b: int
@(align=64)   g_init := Padded{a = true, b = 3, c = {1 = 9}}
g_small: u8

make_big :: #force_no_inline proc(n: int) -> Big {
	return {n, n+1, n+2, n+3, u8(n)}
}

shift_big :: #force_no_inline proc(v: Big) -> Big {
	return {v.a+1, v.b+1, v.c+1, v.d+1, v.tag+1}
}

named_multi :: #force_no_inline proc(n: int) -> (r: Big, ok: bool) {
	r = make_big(n)
	ok = n > 0
	return
}

scribble :: #force_no_inline proc() {
	buf: [8192]byte = ---
	for i in 0..<len(buf) {
		intrinsics.volatile_store(&buf[i], u8(i*7+1))
	}
}

same :: #force_no_inline proc(value, expected: $T) -> bool {
	ok := value == expected
	if !ok {
		fmt.println("differ", value, expected)
	}
	return ok
}

padding_of :: proc(p: rawptr, from, to: int) -> int {
	bytes := ([^]u8)(p)
	s := 0
	for i in from..<to {
		s += int(bytes[i])
	}
	return s
}

inlined_aligned :: proc(n: int) -> uintptr {
	@(align=128) x := n
	return uintptr(&x) % 128
}

forced_aligned :: #force_inline proc(n: int) -> uintptr {
	@(align=256) x: [3]int
	x[0] = n
	return uintptr(&x) % 256
}

recursive_aligned :: #force_no_inline proc(n: int) -> int {
	@(align=512) x := n
	bad := int(uintptr(&x) % 512)
	if n > 0 {
		bad += recursive_aligned(n - 1)
	}
	return bad + x - n
}

generic_aligned :: proc($T: typeid) -> uintptr {
	@(align=max(64, align_of(T))) x: T
	return uintptr(&x) % max(64, align_of(T))
}

returned_aligned :: #force_no_inline proc() -> (Big, uintptr) {
	@(align=256) x := make_big(3)
	return x, uintptr(&x) % 256
}

static_aligned :: #force_no_inline proc() -> uintptr {
	@(static, align=1024) s: int
	s += 1
	return uintptr(&s) % 1024
}

aligned_locals :: #force_no_inline proc() {
	small: u8 = 1
	@(align=512) x: int
	@(align=1024) lit := Padded{a = true, b = 2, c = {3 = 4}}
	@(align=256) sl := []int{1, 2, 3}
	@(align=64) a, b := 1, 2
	w: Wide
	fmt.println("x", uintptr(&x) % 512, x)
	fmt.println("lit", uintptr(&lit) % 1024, lit.b, lit.c[3])
	fmt.println("sl", uintptr(&sl) % 256, len(sl), sl[2])
	fmt.println("a b", uintptr(&a) % 64, uintptr(&b) % 64, a, b)
	fmt.println("wide", uintptr(&w) % 64, align_of(Wide))
	fmt.println("small", uintptr(&small) % 1, small)
	fmt.println("align_of", align_of(x), align_of(lit), align_of(a))
}

rvo_aligned :: #force_no_inline proc() {
	@(align=64) z := make_big(7)
	fmt.println("rvo", uintptr(&z) % 64, z == make_big(7), same(z, make_big(7)), padding_of(&z, 17, size_of(Big)))
	@(align=128) y, ok := named_multi(2)
	fmt.println("multi", uintptr(&y) % 128, ok, same(y, make_big(2)))
}

loop_compare :: #force_no_inline proc() {
	prev: Big
	for i in 0..<4 {
		x := shift_big(prev)
		x.d += i
		prev = x
	}
	fmt.println("loop", same(prev, Big{4, 4, 4, 10, 4}), prev == Big{4, 4, 4, 10, 4})
	x, ok := named_multi(5)
	fmt.println("named", ok, same(x, make_big(5)))
}

uninit_padding :: #force_no_inline proc(n: int) {
	u: Padded = ---
	u.a = true
	u.b = n
	u.c = {}
	fmt.println("uninit", padding_of(&u, 1, align_of(int)), u == Padded{a = true, b = n}, same(u, Padded{a = true, b = n}))
	s: Big = ---
	s.a, s.b, s.c, s.d, s.tag = 1, 2, 3, 4, 5
	fmt.println("uninit big", padding_of(&s, 17, size_of(Big)), s == Big{1, 2, 3, 4, 5}, same(s, Big{1, 2, 3, 4, 5}))
}

main :: proc() {
	fmt.println("globals", uintptr(&g_page) % 4096, uintptr(&g_a) % 128, uintptr(&g_b) % 128, uintptr(&g_init) % 64, g_init.b, g_init.c[1], g_small)
	fmt.println("static", static_aligned(), static_aligned())
	scribble()
	aligned_locals()
	scribble()
	rvo_aligned()
	scribble()
	loop_compare()
	scribble()
	uninit_padding(6)
	fmt.println("inlined", inlined_aligned(3), forced_aligned(4))
	fmt.println("recursive", recursive_aligned(5))
	fmt.println("generic", generic_aligned(u8), generic_aligned(#simd[32]f32), generic_aligned(Wide))
	r, m := returned_aligned()
	fmt.println("returned", m, r)
}
